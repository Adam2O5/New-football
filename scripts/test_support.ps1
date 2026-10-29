#Requires -Version 7.0
Set-StrictMode -Version Latest

function Get-TestSelection {
    param(
        [Parameter(Mandatory)][string] $Root,
        [ValidateSet('standard', 'fast', 'long')][string] $Profile = 'standard',
        [string] $Area
    )

    $testRoot = Join-Path $Root 'test'
    $manifest = Get-Content -LiteralPath (Join-Path $testRoot 'blacklist.json') -Raw | ConvertFrom-Json
    if ($manifest.version -ne 1) { throw 'Unsupported test blacklist version.' }
    $areas = @('ai', 'app', 'balance', 'branding', 'calendar', 'core', 'data', 'integration', 'l10n', 'market', 'match', 'messages', 'performance', 'search', 'staff', 'ui')
    if ($Area -and $Area -cnotin $areas) { throw "Invalid -Area '$Area'. Allowed: $($areas -join ', ')." }
    $files = @(Get-ChildItem -LiteralPath $testRoot -File -Recurse | ForEach-Object {
        [IO.Path]::GetRelativePath($Root, $_.FullName).Replace('\', '/')
    } | Sort-Object)
    $registered = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($entry in $manifest.entries) {
        foreach ($field in @('path', 'originalPath', 'area', 'reason', 'reactivateWhen')) {
            if ([string]::IsNullOrWhiteSpace($entry.$field)) { throw "Blacklist entry requires $field." }
        }
        if ($entry.area -cnotin $areas) { throw "Unknown blacklist area: $($entry.area)" }
        foreach ($path in @($entry.path, $entry.originalPath)) {
            if ($path -cnotmatch '^test/[a-z_]+/[a-zA-Z0-9_./-]+$' -or $path -match '(^|/)\.\.(/|$)') {
                throw "Unsafe blacklist path: $path"
            }
            if ($path.Split('/')[1] -cne $entry.area) { throw "Blacklist area does not match: $path" }
        }
        if ($entry.long -isnot [bool]) { throw "Blacklist long must be boolean: $($entry.path)" }
        if ($entry.path -cnotmatch '\.dart\.disabled$' -or
            ($entry.long -and $entry.path -cnotmatch '/long/[^/]+_long\.dart\.disabled$') -or
            (!$entry.long -and $entry.path -cnotmatch '/disabled/')) {
            throw "Invalid disabled filename: $($entry.path)"
        }
        if (!$registered.Add($entry.path)) { throw "Duplicate blacklist path: $($entry.path)" }
        if ($entry.path -cnotin $files) { throw "Missing blacklisted file: $($entry.path)" }
    }
    foreach ($file in $files) {
        if ($file.EndsWith('.dart') -and $file -match '/disabled/') {
            throw "Disabled source must use .dart.disabled: $file"
        }
        if ($file.EndsWith('.dart.disabled') -and !$registered.Contains($file)) {
            throw "Unregistered disabled source: $file"
        }
        if ($file.EndsWith('_test.dart') -and $file -match '/(long|disabled)/') {
            throw "Default discovery would include an isolated test: $file"
        }
        if ($file.EndsWith('_long.dart') -and $file -notmatch '/long/') {
            throw "Long test must be inside its area's long directory: $file"
        }
    }
    $active = @($files | Where-Object { $_.EndsWith('_test.dart') })
    $long = @($files | Where-Object { $_.EndsWith('_long.dart') })
    foreach ($file in @($active + $long)) {
        if ((Get-Content -LiteralPath (Join-Path $Root $file) -Raw) -match '(?m)^\s*(?:import|export|part)\s+[''"][^''"]+\.disabled[''"]') {
            throw "Active source imports disabled code: $file"
        }
    }
    $selected = if ($Profile -eq 'long') { @($long) } else { @($active) }
    if ($Area) { $selected = @($selected | Where-Object { $_.StartsWith("test/$Area/") }) }
    [pscustomobject]@{
        Files = @($selected)
        ActiveCount = $active.Count
        LongCount = $long.Count
        BlacklistedCount = $registered.Count
    }
}

function Invoke-BoundedTestProcess {
    param(
        [Parameter(Mandatory)][string] $Executable,
        [string[]] $Arguments = @(),
        [Parameter(Mandatory)][string] $WorkingDirectory,
        [Parameter(Mandatory)][string] $LogDirectory,
        [ValidateRange(1, 86400)][int] $TimeoutSeconds
    )
    [IO.Directory]::CreateDirectory($LogDirectory) | Out-Null
    $start = [Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $Executable
    $start.WorkingDirectory = $WorkingDirectory
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($argument in $Arguments) { $start.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $start
    $stdout = [IO.FileStream]::new((Join-Path $LogDirectory 'stdout.log'), [IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::ReadWrite, 1, $true)
    $stderr = [IO.FileStream]::new((Join-Path $LogDirectory 'stderr.log'), [IO.FileMode]::Create, [IO.FileAccess]::Write, [IO.FileShare]::ReadWrite, 1, $true)
    $started = $false
    $timedOut = $false
    $clock = [Diagnostics.Stopwatch]::StartNew()
    try {
        $started = $process.Start()
        $outCopy = $process.StandardOutput.BaseStream.CopyToAsync($stdout)
        $errCopy = $process.StandardError.BaseStream.CopyToAsync($stderr)
        while (!$process.HasExited -or !$outCopy.IsCompleted -or !$errCopy.IsCompleted) {
            if ($clock.Elapsed.TotalSeconds -ge $TimeoutSeconds) {
                $timedOut = $true
                if (!$process.HasExited) { $process.Kill($true) }
                break
            }
            Start-Sleep -Milliseconds 50
        }
        if (!$process.WaitForExit(5000)) { throw 'Test process did not terminate after kill.' }
        if (!$outCopy.Wait(5000) -or !$errCopy.Wait(5000)) { throw 'Test output did not close after process exit.' }
        $code = if ($timedOut) { 124 } else { $process.ExitCode }
        $status = if ($timedOut) { 'TIMEOUT' } elseif ($code -eq 0) { 'PASS' } else { 'FAIL' }
        $result = [pscustomobject]@{ Status = $status; ExitCode = $code; Seconds = [Math]::Round($clock.Elapsed.TotalSeconds, 2); ProcessId = $process.Id }
        $result | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $LogDirectory 'result.json') -Encoding utf8
        return $result
    } finally {
        if ($started -and !$process.HasExited) {
            $process.Kill($true)
            $process.WaitForExit(5000) | Out-Null
        }
        $stdout.Dispose()
        $stderr.Dispose()
        $process.Dispose()
    }
}
