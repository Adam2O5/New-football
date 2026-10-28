#Requires -Version 7.0
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $repoRoot 'scripts/test_support.ps1')
$pwsh = (Get-Process -Id $PID).Path
function Assert([bool] $Condition, [string] $Message) { if (!$Condition) { throw $Message } }
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$fixture = Join-Path $tempRoot ("football-runner-process-" + [guid]::NewGuid())
[IO.Directory]::CreateDirectory($fixture) | Out-Null
try {
    foreach ($code in @(0, 7)) {
        $result = Invoke-BoundedTestProcess -Executable $pwsh -Arguments @('-NoProfile', '-Command', "Write-Output 'literal space'; [Console]::Error.WriteLine('stderr'); exit $code") -WorkingDirectory $fixture -LogDirectory (Join-Path $fixture "exit-$code") -TimeoutSeconds 10
        Assert ($result.ExitCode -eq $code) 'Child exit code was lost.'
        Assert ($result.Status -eq $(if ($code -eq 0) { 'PASS' } else { 'FAIL' })) 'Incorrect status.'
        Assert ((Get-Content -LiteralPath (Join-Path $fixture "exit-$code/stdout.log") -Raw).Contains('literal space')) 'stdout was lost.'
        Assert ((Get-Content -LiteralPath (Join-Path $fixture "exit-$code/stderr.log") -Raw).Contains('stderr')) 'stderr was lost.'
    }
    $worker = Join-Path $fixture 'parent with spaces.ps1'
    @'
param([string] $ChildPidPath)
$start = [Diagnostics.ProcessStartInfo]::new()
$start.FileName = (Get-Process -Id $PID).Path
$start.UseShellExecute = $false
$start.CreateNoWindow = $true
foreach ($arg in @('-NoProfile', '-Command', 'Start-Sleep -Seconds 60')) { $start.ArgumentList.Add($arg) }
$child = [Diagnostics.Process]::Start($start)
[IO.File]::WriteAllText($ChildPidPath, [string]$child.Id)
Write-Output 'child started'
Start-Sleep -Seconds 60
'@ | Set-Content -LiteralPath $worker
    $marker = Join-Path $fixture 'child.pid'
    $result = Invoke-BoundedTestProcess -Executable $pwsh -Arguments @('-NoProfile', '-File', $worker, $marker) -WorkingDirectory $fixture -LogDirectory (Join-Path $fixture 'timeout') -TimeoutSeconds 4
    Assert ($result.ExitCode -eq 124 -and $result.Status -eq 'TIMEOUT') 'Timeout must be distinguishable from a test failure.'
    Assert (Test-Path -LiteralPath $marker) 'Fixture did not start its child before the deadline.'
    $childId = [int](Get-Content -LiteralPath $marker -Raw)
    foreach ($processId in @($result.ProcessId, $childId)) {
        $remaining = Get-Process -Id $processId -ErrorAction SilentlyContinue
        Assert ($null -eq $remaining -or $remaining.HasExited) "Timed-out process survived: $processId"
    }
    $saved = Get-Content -LiteralPath (Join-Path $fixture 'timeout/result.json') -Raw | ConvertFrom-Json
    Assert ($saved.Status -eq 'TIMEOUT') 'Persisted timeout diagnostics are missing.'
    Write-Host 'PASS: exit codes, stdout/stderr, spaced arguments and timeout of parent/child tree.'
} finally {
    $resolvedFixture = [IO.Path]::GetFullPath($fixture)
    if (!$resolvedFixture.StartsWith($tempRoot) -or !(Split-Path -Leaf $resolvedFixture).StartsWith('football-runner-process-')) { throw 'Unsafe fixture cleanup target.' }
    if (Test-Path -LiteralPath $resolvedFixture) { Remove-Item -LiteralPath $resolvedFixture -Recurse -Force }
}
