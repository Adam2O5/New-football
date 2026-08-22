[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Property 3: every test import containing helpers/ resolves to a file in
# test/helpers when interpreted relative to the importing test file.
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$testRoot = Join-Path $repoRoot 'test'
$helpersRoot = Join-Path $testRoot 'helpers'
$violations = New-Object 'System.Collections.Generic.List[string]'
$importPattern = '(?m)^\s*import\s+(?<quote>[''\"])(?<uri>[^''\"]*)\k<quote>'

function Add-Violation {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    [void] $violations.Add($Message)
}

function Get-RepoRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    $relativePath = $Path.Substring($repoRoot.Length) -replace '^[\\/]+', ''
    return ($relativePath -replace '\\', '/')
}

function Get-NormalizedImportPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ImportingDirectory,
        [Parameter(Mandatory = $true)]
        [string] $ImportUri
    )

    $nativeUriPath = $ImportUri -replace '/', [System.IO.Path]::DirectorySeparatorChar
    $combinedPath = Join-Path -Path $ImportingDirectory -ChildPath $nativeUriPath
    return [System.IO.Path]::GetFullPath($combinedPath)
}

function Test-PathWithinDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string] $CandidatePath,
        [Parameter(Mandatory = $true)]
        [string] $DirectoryPath
    )

    $directory = $DirectoryPath.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $candidate = $CandidatePath.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $directoryPrefix = $directory + [System.IO.Path]::DirectorySeparatorChar

    return $candidate.Equals($directory, [System.StringComparison]::OrdinalIgnoreCase) -or
        $candidate.StartsWith($directoryPrefix, [System.StringComparison]::OrdinalIgnoreCase)
}

$testFiles = @()
$helperImportCount = 0
$filesWithHelperImports = @{}

if (-not (Test-Path -LiteralPath $testRoot -PathType Container)) {
    Add-Violation "Test root does not exist: '$testRoot'."
}

if (-not (Test-Path -LiteralPath $helpersRoot -PathType Container)) {
    Add-Violation "Helpers folder does not exist: '$helpersRoot'."
}

if (Test-Path -LiteralPath $testRoot -PathType Container) {
    # Enumerate every test file, including files in nested domain folders.
    $testFiles = @(Get-ChildItem -LiteralPath $testRoot -Recurse -File -Filter '*_test.dart' -Force)

    foreach ($file in $testFiles) {
        $relativeFile = Get-RepoRelativePath -Path $file.FullName
        $content = $null

        try {
            $content = [System.IO.File]::ReadAllText($file.FullName)
        }
        catch {
            Add-Violation ("file='{0}'; import='<unreadable>'; normalized='<unavailable>'; reason=unable to read test file: {1}" -f $relativeFile, $_.Exception.Message)
            continue
        }

        # Match import directives only. Documentation references such as
        # `helpers/foo.dart` are intentionally not treated as imports.
        $importMatches = [regex]::Matches($content, $importPattern)
        foreach ($importMatch in $importMatches) {
            $importUri = $importMatch.Groups['uri'].Value
            if (-not $importUri.Contains('helpers/')) {
                continue
            }

            $helperImportCount++
            $filesWithHelperImports[$file.FullName] = $true
            $normalizedPath = $null

            try {
                $normalizedPath = Get-NormalizedImportPath -ImportingDirectory $file.DirectoryName -ImportUri $importUri
            }
            catch {
                Add-Violation ("file='{0}'; import='{1}'; normalized='<invalid path>'; reason=unable to normalize import URI: {2}" -f $relativeFile, $importUri, $_.Exception.Message)
                continue
            }

            if (-not (Test-Path -LiteralPath $normalizedPath -PathType Leaf)) {
                Add-Violation ("file='{0}'; import='{1}'; normalized='{2}'; reason=target does not exist" -f $relativeFile, $importUri, $normalizedPath)
                continue
            }

            if (-not (Test-PathWithinDirectory -CandidatePath $normalizedPath -DirectoryPath $helpersRoot)) {
                Add-Violation ("file='{0}'; import='{1}'; normalized='{2}'; reason=target is outside test/helpers" -f $relativeFile, $importUri, $normalizedPath)
            }
        }
    }
}

if ($violations.Count -gt 0) {
    Write-Host "Helper import verification FAILED with $($violations.Count) violation(s)." -ForegroundColor Red
    foreach ($violation in $violations) {
        Write-Host "ERROR: $violation" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Helper import verification passed.' -ForegroundColor Green
Write-Host "  Test files checked: $($testFiles.Count)"
Write-Host "  Helper imports checked: $helperImportCount across $($filesWithHelperImports.Count) test files"
Write-Host "  Helper target root: '$(Get-RepoRelativePath -Path $helpersRoot)'"
exit 0
