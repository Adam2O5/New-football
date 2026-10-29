#Requires -Version 7.0
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
. (Join-Path $repoRoot 'scripts/test_support.ps1')
$runner = Join-Path $repoRoot 'scripts/test.ps1'
$pwsh = (Get-Process -Id $PID).Path
function Assert([bool] $Condition, [string] $Message) { if (!$Condition) { throw $Message } }
function Assert-Rejected([scriptblock] $Action) {
    $rejected = $false
    try { & $Action | Out-Null } catch { $rejected = $true }
    Assert $rejected 'Expected invalid selection/manifest to be rejected.'
}
function Invoke-Runner([string[]] $RunnerArguments) {
    $output = @(& $pwsh -NoProfile -NonInteractive -File $runner @RunnerArguments 2>&1)
    [pscustomobject]@{ Code = $LASTEXITCODE; Text = ($output -join [Environment]::NewLine) }
}
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$fixture = Join-Path $tempRoot ("football-runner-selection-" + [guid]::NewGuid())
try {
    foreach ($path in @('test/data/value_test.dart', 'test/data/long/value_long.dart', 'test/ai/disabled/ai_test.dart.disabled')) {
        $full = Join-Path $fixture $path
        [IO.Directory]::CreateDirectory((Split-Path -Parent $full)) | Out-Null
        [IO.File]::WriteAllText($full, 'void main() {}')
    }
    $entry = [pscustomobject]@{ path = 'test/ai/disabled/ai_test.dart.disabled'; originalPath = 'test/ai/ai_test.dart'; area = 'ai'; reason = 'AI deferred'; reactivateWhen = 'AI implemented'; long = $false }
    $manifestPath = Join-Path $fixture 'test/blacklist.json'
    function Set-Manifest($Entries) {
        @{ version = 1; entries = @($Entries) } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath
    }
    Set-Manifest @($entry)
    $standard = Get-TestSelection -Root $fixture
    Assert ($standard.Files.Count -eq 1 -and $standard.Files[0] -eq 'test/data/value_test.dart') 'Standard must select only active files.'
    Assert ($standard.LongCount -eq 1 -and $standard.BlacklistedCount -eq 1) 'Excluded counts must remain visible.'
    $long = Get-TestSelection -Root $fixture -Profile long
    Assert ($long.Files.Count -eq 1 -and $long.Files[0] -eq 'test/data/long/value_long.dart') 'Long must select only explicit long files.'
    Assert ((Get-TestSelection -Root $fixture -Area ai).Files.Count -eq 0) 'Blacklisted-only area must be empty.'
    Assert-Rejected { Get-TestSelection -Root $fixture -Area helpers }
    Assert-Rejected { Get-TestSelection -Root $fixture -Area '../data' }
    Set-Manifest @($entry, $entry)
    Assert-Rejected { Get-TestSelection -Root $fixture }
    Set-Manifest @()
    Assert-Rejected { Get-TestSelection -Root $fixture }
    $invalid = $entry | Select-Object *
    $invalid.path = 'test/ai/../outside.dart.disabled'
    Set-Manifest @($invalid)
    Assert-Rejected { Get-TestSelection -Root $fixture }
    $invalid.path = 'test/ai/disabled/missing_test.dart.disabled'
    Set-Manifest @($invalid)
    Assert-Rejected { Get-TestSelection -Root $fixture }
    Set-Manifest @($entry)
    $discovered = Join-Path $fixture 'test/data/long/leaked_test.dart'
    [IO.File]::WriteAllText($discovered, 'void main() {}')
    Assert-Rejected { Get-TestSelection -Root $fixture }

    $real = Get-TestSelection -Root $repoRoot
    $discovery = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'test') -Filter '*_test.dart' -File -Recurse)
    Assert ($real.Files.Count -eq $discovery.Count) 'Wrapper and default filename discovery must agree.'
    foreach ($area in @('ai', 'app', 'balance', 'branding', 'calendar', 'core', 'data', 'integration', 'l10n', 'market', 'match', 'messages', 'performance', 'search', 'staff', 'ui')) {
        $selection = Get-TestSelection -Root $repoRoot -Area $area
        Assert (@($selection.Files | Where-Object { !$_.StartsWith("test/$area/") }).Count -eq 0) "Area leaked other files: $area"
    }
    $dry = Invoke-Runner @('-Area', 'search', '-Fast', '-Coverage', '-Tags', 'unit', '-ExcludeTags', 'asset', '-DryRun')
    Assert ($dry.Code -eq 0 -and $dry.Text.Contains('slow || benchmark || integration || asset')) 'Fast/exclusions must compose.'
    Assert ($dry.Text.Contains('--coverage') -and $dry.Text.Contains('-t unit')) 'Coverage and tags must be preserved.'
    $yaml = Get-Content -LiteralPath (Join-Path $repoRoot 'dart_test.yaml') -Raw
    Assert ($yaml.Contains('slow || benchmark || integration')) 'Fast preset must agree with wrapper.'
    Assert ((Invoke-Runner @('-Area', 'ai', '-DryRun')).Code -eq 0) 'Empty dry run should explain selection.'
    Assert ((Invoke-Runner @('-Area', 'ai')).Code -ne 0) 'Empty selection must never fall back to all tests.'
    Assert ((Invoke-Runner @('-Fast', '-Profile', 'standard', '-DryRun')).Code -ne 0) 'Conflicting options must fail.'
    Assert ((Invoke-Runner @('-Area', 'unknown', '-DryRun')).Code -ne 0) 'Unknown area must fail.'
    $previousCI = $env:CI
    try {
        $env:CI = 'true'
        $blocked = Invoke-Runner @('-Profile', 'long', '-DryRun')
        Assert ($blocked.Code -ne 0 -and $blocked.Text.Contains('cannot run in CI')) 'CI must reject long, even during dry run.'
    } finally { $env:CI = $previousCI }
    Write-Host 'PASS: selection, blacklist validation, discovery, CLI options and CI guard.'
} finally {
    $resolvedFixture = [IO.Path]::GetFullPath($fixture)
    if (!$resolvedFixture.StartsWith($tempRoot) -or !(Split-Path -Leaf $resolvedFixture).StartsWith('football-runner-selection-')) { throw 'Unsafe fixture cleanup target.' }
    if (Test-Path -LiteralPath $resolvedFixture) { Remove-Item -LiteralPath $resolvedFixture -Recurse -Force }
}
