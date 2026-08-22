[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Property 1: every test suite belongs to exactly one allowed domain folder.
# Property 2: the basename multiset must match baseline_files.txt exactly.
$allowedDomains = @(
    'match',
    'ai',
    'market',
    'calendar',
    'staff',
    'messages',
    'data',
    'ui',
    'balance'
)
$expectedFileCount = 99
$helpersDirectoryName = 'helpers'

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$testRoot = Join-Path $repoRoot 'test'
$baselinePath = Join-Path $repoRoot 'baseline_files.txt'
$violations = New-Object 'System.Collections.Generic.List[string]'

function Add-Violation {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    [void] $violations.Add($Message)
}

if (-not (Test-Path -LiteralPath $testRoot -PathType Container)) {
    Add-Violation "Test root does not exist: '$testRoot'."
}

if (-not (Test-Path -LiteralPath $baselinePath -PathType Leaf)) {
    Add-Violation "Baseline inventory does not exist: '$baselinePath'."
}

$testFiles = @()
if (Test-Path -LiteralPath $testRoot -PathType Container) {
    $helpersRoot = Join-Path $testRoot $helpersDirectoryName
    if (-not (Test-Path -LiteralPath $helpersRoot -PathType Container)) {
        Add-Violation "Required helpers folder is missing: 'test/$helpersDirectoryName/'."
    }

    # This is the required test/**/*_test.dart enumeration.
    $testFiles = @(Get-ChildItem -LiteralPath $testRoot -Recurse -File -Filter '*_test.dart' -Force)

    $topLevelDirectories = @(
        Get-ChildItem -LiteralPath $testRoot -Directory -Force |
            Select-Object -ExpandProperty Name
    )

    foreach ($domain in $allowedDomains) {
        if ($topLevelDirectories -cnotcontains $domain) {
            Add-Violation "Required domain folder is missing: 'test/$domain/'."
        }
    }

    foreach ($directory in $topLevelDirectories) {
        if (($allowedDomains -cnotcontains $directory) -and ($directory -cne $helpersDirectoryName)) {
            Add-Violation "Unexpected top-level folder under test/: 'test/$directory/'. Allowed domain folders are: $($allowedDomains -join ', '); '$helpersDirectoryName/' is reserved for helpers."
        }
    }
}

if ($testFiles.Count -ne $expectedFileCount) {
    Add-Violation "Expected exactly $expectedFileCount test files matching test/**/*_test.dart; found $($testFiles.Count)."
}

$validRecords = @()
foreach ($file in $testFiles) {
    $relativePath = $file.FullName.Substring($testRoot.Length) -replace '^[\\/]+', ''
    $relativePath = $relativePath -replace '\\', '/'
    $parts = @($relativePath -split '/')

    if ($parts.Count -eq 1) {
        Add-Violation "Test file is directly under test/: '$relativePath'. Expected test/<domain>/<file>_test.dart."
        continue
    }

    if ($parts[0] -ceq $helpersDirectoryName) {
        Add-Violation "Test file is under test/helpers/: '$relativePath'. Helpers must not contain test suites."
        continue
    }

    if ($parts.Count -ne 2) {
        Add-Violation "Test file has invalid nesting: '$relativePath'. Expected exactly one domain-level folder: test/<domain>/<file>_test.dart."
        continue
    }

    $domain = $parts[0]
    if ($allowedDomains -cnotcontains $domain) {
        Add-Violation "Test file uses an invalid domain '$domain': '$relativePath'. Allowed domains are: $($allowedDomains -join ', ')."
        continue
    }

    $validRecords += [pscustomobject]@{
        FileName = $file.Name
        Domain = $domain
        RelativePath = $relativePath
    }
}

# Detect the same basename in more than one domain. A duplicate in one domain
# is impossible on a normal filesystem, but the comparison remains explicitly
# domain-aware to enforce the requirement as written.
$nameGroups = @()
foreach ($record in $validRecords) {
    $group = @($nameGroups | Where-Object { $_.FileName -ceq $record.FileName } | Select-Object -First 1)
    if ($null -eq $group -or $group.Count -eq 0) {
        $nameGroups += [pscustomobject]@{
            FileName = $record.FileName
            Records = @($record)
        }
    }
    else {
        $group[0].Records = @($group[0].Records) + $record
    }
}

foreach ($group in $nameGroups) {
    $domains = @($group.Records | ForEach-Object { $_.Domain } | Sort-Object -Unique)
    if ($domains.Count -gt 1) {
        $paths = @($group.Records | ForEach-Object { $_.RelativePath } | Sort-Object)
        Add-Violation "Duplicate test filename '$($group.FileName)' appears across domains: $($paths -join ', ')."
    }
}

$actualNames = @($testFiles | ForEach-Object { $_.Name } | Sort-Object -CaseSensitive)
if (Test-Path -LiteralPath $baselinePath -PathType Leaf) {
    $baselineNames = @(Get-Content -LiteralPath $baselinePath | Sort-Object -CaseSensitive)

    if ($baselineNames.Count -ne $expectedFileCount) {
        Add-Violation "Baseline inventory must contain exactly $expectedFileCount filenames; found $($baselineNames.Count) in '$baselinePath'."
    }

    # Compare sorted entries by position so duplicate names are counted too;
    # this is a multiset comparison, not merely a set comparison.
    $maxNameCount = [Math]::Max($baselineNames.Count, $actualNames.Count)
    for ($index = 0; $index -lt $maxNameCount; $index++) {
        $hasBaselineName = $index -lt $baselineNames.Count
        $hasActualName = $index -lt $actualNames.Count

        if (-not $hasBaselineName) {
            Add-Violation "Test filename is not present in baseline_files.txt: '$($actualNames[$index])'."
            continue
        }

        if (-not $hasActualName) {
            Add-Violation "Baseline filename is missing from the test layout: '$($baselineNames[$index])'."
            continue
        }

        if ($baselineNames[$index] -cne $actualNames[$index]) {
            Add-Violation "Baseline filename multiset mismatch at sorted position $index: baseline '$($baselineNames[$index])', actual '$($actualNames[$index])'."
        }
    }
}

if ($violations.Count -gt 0) {
    Write-Host "Layout verification FAILED with $($violations.Count) violation(s)." -ForegroundColor Red
    foreach ($violation in $violations) {
        Write-Host "ERROR: $violation" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Layout verification passed." -ForegroundColor Green
Write-Host "  Test files checked: $($testFiles.Count)"
Write-Host "  Allowed domains: $($allowedDomains -join ', ')"
Write-Host "  Partition: every file is exactly test/<domain>/<file>_test.dart"
Write-Host "  Helpers: no test files under test/helpers/"
Write-Host "  Duplicate basenames across domains: none"
Write-Host "  Baseline: '$baselinePath' ($($actualNames.Count) filenames)"
exit 0
