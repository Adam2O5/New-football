#Requires -Version 7.0
[CmdletBinding()]
param(
    [string] $Area,
    [ValidateSet('standard', 'fast', 'long')][string] $Profile = 'standard',
    [switch] $Fast,
    [string[]] $Tags,
    [string[]] $ExcludeTags,
    [switch] $Coverage,
    [switch] $DryRun,
    [ValidateRange(1, 86400)][int] $TimeoutSeconds
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'test_support.ps1')
$repoRoot = Split-Path -Parent $PSScriptRoot
try {
    if ($PSBoundParameters.ContainsKey('Area') -and [string]::IsNullOrWhiteSpace($Area)) { throw '-Area must not be empty.' }
    if ($Fast) {
        if ($PSBoundParameters.ContainsKey('Profile') -and $Profile -ne 'fast') { throw '-Fast conflicts with -Profile. Use either option.' }
        $Profile = 'fast'
    }
    if ($Profile -eq 'long' -and ($env:CI -and $env:CI -notin @('false', '0'))) { throw 'The long profile is manual-only and cannot run in CI.' }
    if ($Profile -eq 'long' -and $Coverage) { throw 'Coverage is supported for active tests, not the long profile.' }
    $selection = Get-TestSelection -Root $repoRoot -Area $Area -Profile $Profile
    Write-Host "Profile: $Profile; active: $($selection.ActiveCount); long files: $($selection.LongCount); BLACKLISTED: $($selection.BlacklistedCount)"
    if (!$TimeoutSeconds) { $TimeoutSeconds = if ($Profile -eq 'long') { 900 } else { 600 } }
    $excluded = @($ExcludeTags)
    if ($Profile -eq 'fast') { $excluded = @('slow', 'benchmark', 'integration') + $excluded }
    $excluded = @($excluded | Where-Object { $_ } | Select-Object -Unique)
    $selectedTags = @($Tags | Where-Object { $_ } | Select-Object -Unique)
    $flutterArguments = @('test', '--no-pub', '--reporter', 'expanded', '--timeout', '30s')
    if ($excluded.Count) { $flutterArguments += @('-x', ($excluded -join ' || ')) }
    if ($selectedTags.Count) { $flutterArguments += @('-t', ($selectedTags -join ' || ')) }
    if ($Coverage) { $flutterArguments += '--coverage' }
    Write-Host "Selected: $($selection.Files.Count); process budget: $TimeoutSeconds seconds"
    if ($Profile -ne 'long') { Write-Host "LONG_NOT_RUN: $($selection.LongCount)" }
    if ($DryRun) {
        Write-Host "flutter $($flutterArguments -join ' ')"
        $selection.Files | ForEach-Object { Write-Host $_ }
        if (!$Area -and $env:GITHUB_STEP_SUMMARY) {
            "Test selection: $Profile. Active files: $($selection.ActiveCount). Selected: $($selection.Files.Count). Long files: $($selection.LongCount). BLACKLISTED: $($selection.BlacklistedCount). Execution not started." | Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY
        }
        exit 0
    }
    if (!$selection.Files.Count) { throw "No executable tests for profile '$Profile' and area '$Area'." }

    # Bypass flutter.bat: explicit file lists can exceed cmd.exe's 8191 characters.
    $flutter = Get-Command flutter -CommandType Application -ErrorAction Stop | Select-Object -First 1
    $flutterBin = Split-Path -Parent $flutter.Source
    $dartName = if ($IsWindows) { 'dart.exe' } else { 'dart' }
    $dart = Join-Path $flutterBin "cache/dart-sdk/bin/$dartName"
    $snapshot = Join-Path $flutterBin 'cache/flutter_tools.snapshot'
    if (!(Test-Path -LiteralPath $dart) -or !(Test-Path -LiteralPath $snapshot)) { throw 'Flutter SDK cache is missing. Run flutter --version first.' }
    $logRoot = Join-Path $repoRoot "build/test-results/$([DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss-fff'))-$PID"
    [IO.Directory]::CreateDirectory($logRoot) | Out-Null
    $selection.Files | Set-Content -LiteralPath (Join-Path $logRoot 'selected-files.txt') -Encoding utf8
    $batches = [Collections.Generic.List[object]]::new()
    if ($Profile -eq 'long') {
        foreach ($file in $selection.Files) { $batches.Add(@($file)) }
    } else {
        $batches.Add($selection.Files)
    }
    $exitCode = 0
    $results = @()
    $index = 0
    foreach ($batch in $batches) {
        $index++
        $directory = Join-Path $logRoot "run-$index"
        Write-Host "Starting run $index; logs (updated live): $directory"
        $result = Invoke-BoundedTestProcess -Executable $dart -Arguments (@($snapshot) + $flutterArguments + @($batch)) -WorkingDirectory $repoRoot -LogDirectory $directory -TimeoutSeconds $TimeoutSeconds
        $results += $result
        Write-Host "$($result.Status): exit=$($result.ExitCode), seconds=$($result.Seconds)"
        foreach ($name in @('stdout.log', 'stderr.log')) {
            # A failed GameSave matcher can print megabytes in one line.
            # Keep console diagnostics bounded; the complete log remains on disk.
            $tail = [IO.File]::OpenRead((Join-Path $directory $name))
            try {
                $tail.Position = [Math]::Max(0, $tail.Length - 16384)
                $buffer = [byte[]]::new(16384)
                $read = $tail.Read($buffer, 0, $buffer.Length)
                ([Text.Encoding]::UTF8.GetString($buffer, 0, $read) -split '\r?\n' | Select-Object -Last 15) | ForEach-Object {
                    Write-Host $_.Substring(0, [Math]::Min($_.Length, 1000))
                }
            } finally {
                $tail.Dispose()
            }
        }
        if ($result.ExitCode -ne 0 -and $exitCode -eq 0) { $exitCode = $result.ExitCode }
    }
    $summary = [pscustomobject]@{ Profile = $Profile; Active = $selection.ActiveCount; LongFiles = $selection.LongCount; Blacklisted = $selection.BlacklistedCount; Selected = $selection.Files.Count; Results = $results }
    $summary | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $logRoot 'summary.json') -Encoding utf8
    if ($env:GITHUB_STEP_SUMMARY) {
        "Test profile: $Profile. Active files: $($selection.ActiveCount). Selected: $($selection.Files.Count). Long files: $($selection.LongCount). BLACKLISTED: $($selection.BlacklistedCount). Exit: $exitCode." | Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY
    }
    exit $exitCode
} catch {
    Write-Error $_ -ErrorAction Continue
    exit 2
}
