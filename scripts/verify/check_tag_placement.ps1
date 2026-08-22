[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$testRoot = Join-Path $repoRoot 'test'
$violations = New-Object 'System.Collections.Generic.List[string]'

function Add-Violation {
    param(
        [Parameter(Mandatory = $true)]
        [string] $RelativePath,

        [Parameter(Mandatory = $true)]
        [int] $Line,

        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    [void] $violations.Add(("{0}:{1}: {2}" -f $RelativePath, $Line, $Message))
}

function Get-RelativeTestPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $FilePath
    )

    return (($FilePath.Substring($testRoot.Length) -replace '^[\\/]+', '') -replace '\\', '/')
}

function Get-LineNumber {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Text,

        [Parameter(Mandatory = $true)]
        [int] $Index
    )

    if ($Index -le 0) {
        return 1
    }

    return ([regex]::Matches($Text.Substring(0, $Index), "`n").Count + 1)
}

# Replace comments and string contents with spaces while preserving every newline
# and character offset. This keeps the structural checks from matching an
# @Tags or tags: that appears only in a comment/string literal.
function ConvertTo-DartCode {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Text
    )

    $builder = New-Object System.Text.StringBuilder
    $state = 'code'
    $quote = [char] 0
    $tripleQuote = $false
    $escaped = $false
    $index = 0

    while ($index -lt $Text.Length) {
        $character = $Text[$index]

        if ($state -eq 'lineComment') {
            if (($character -eq [char] 13) -or ($character -eq [char] 10)) {
                [void] $builder.Append($character)
                $state = 'code'
            }
            else {
                [void] $builder.Append(' ')
            }
            $index++
            continue
        }

        if ($state -eq 'blockComment') {
            if (($character -eq [char] 42) -and
                ($index + 1 -lt $Text.Length) -and
                ($Text[$index + 1] -eq [char] 47)) {
                [void] $builder.Append(' ')
                [void] $builder.Append(' ')
                $index += 2
                $state = 'code'
                continue
            }

            if (($character -eq [char] 13) -or ($character -eq [char] 10)) {
                [void] $builder.Append($character)
            }
            else {
                [void] $builder.Append(' ')
            }
            $index++
            continue
        }

        if ($state -eq 'string') {
            if ($escaped) {
                if (($character -eq [char] 13) -or ($character -eq [char] 10)) {
                    [void] $builder.Append($character)
                }
                else {
                    [void] $builder.Append(' ')
                }
                $escaped = $false
                $index++
                continue
            }

            if ($character -eq [char] 92) {
                [void] $builder.Append(' ')
                $escaped = $true
                $index++
                continue
            }

            if (($tripleQuote) -and
                ($character -eq $quote) -and
                ($index + 2 -lt $Text.Length) -and
                ($Text[$index + 1] -eq $quote) -and
                ($Text[$index + 2] -eq $quote)) {
                [void] $builder.Append(' ')
                [void] $builder.Append(' ')
                [void] $builder.Append(' ')
                $index += 3
                $state = 'code'
                $tripleQuote = $false
                continue
            }

            if ((-not $tripleQuote) -and ($character -eq $quote)) {
                [void] $builder.Append(' ')
                $index++
                $state = 'code'
                continue
            }

            if (($character -eq [char] 13) -or ($character -eq [char] 10)) {
                [void] $builder.Append($character)
            }
            else {
                [void] $builder.Append(' ')
            }
            $index++
            continue
        }

        if (($character -eq [char] 47) -and
            ($index + 1 -lt $Text.Length) -and
            ($Text[$index + 1] -eq [char] 47)) {
            [void] $builder.Append(' ')
            [void] $builder.Append(' ')
            $index += 2
            $state = 'lineComment'
            continue
        }

        if (($character -eq [char] 47) -and
            ($index + 1 -lt $Text.Length) -and
            ($Text[$index + 1] -eq [char] 42)) {
            [void] $builder.Append(' ')
            [void] $builder.Append(' ')
            $index += 2
            $state = 'blockComment'
            continue
        }

        if (($character -eq [char] 39) -or ($character -eq [char] 34)) {
            $quote = $character
            $tripleQuote = (($index + 2 -lt $Text.Length) -and
                ($Text[$index + 1] -eq $character) -and
                ($Text[$index + 2] -eq $character))
            [void] $builder.Append(' ')
            if ($tripleQuote) {
                [void] $builder.Append(' ')
                [void] $builder.Append(' ')
                $index += 3
            }
            else {
                $index++
            }
            $escaped = $false
            $state = 'string'
            continue
        }

        [void] $builder.Append($character)
        $index++
    }

    return $builder.ToString()
}

function Find-MatchingParen {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Text,

        [Parameter(Mandatory = $true)]
        [int] $OpenIndex
    )

    $depth = 0
    for ($index = $OpenIndex; $index -lt $Text.Length; $index++) {
        if ($Text[$index] -eq [char] 40) {
            $depth++
        }
        elseif ($Text[$index] -eq [char] 41) {
            $depth--
            if ($depth -eq 0) {
                return $index
            }
        }
    }

    return -1
}

$testFiles = @()
if (-not (Test-Path -LiteralPath $testRoot -PathType Container)) {
    Add-Violation 'test/' 1 "Test root does not exist: '$testRoot'."
}
else {
    $testFiles = @(
        Get-ChildItem -LiteralPath $testRoot -Recurse -File -Filter '*_test.dart' -Force |
            Sort-Object -Property FullName
    )
}

$taggedFileCount = 0
foreach ($file in $testFiles) {
    $relativePath = Get-RelativeTestPath -FilePath $file.FullName
    $source = [System.IO.File]::ReadAllText($file.FullName)
    $code = ConvertTo-DartCode -Text $source

    $tagMatches = @([regex]::Matches($code, '(?<![\w$])@Tags\b'))
    if ($tagMatches.Count -gt 0) {
        $taggedFileCount++
    }

    $firstImport = [regex]::Match($code, '(?m)^[\t ]*import\b')
    $firstImportLine = 0
    if ($firstImport.Success) {
        $firstImportLine = Get-LineNumber -Text $code -Index $firstImport.Index
    }

    if ($tagMatches.Count -gt 1) {
        $tagLines = @(
            $tagMatches | ForEach-Object {
                Get-LineNumber -Text $code -Index $_.Index
            }
        )
        Add-Violation -RelativePath $relativePath -Line $tagLines[0] -Message ("Found {0} @Tags annotations on lines {1}; at most one file-level annotation is allowed." -f $tagMatches.Count, ($tagLines -join ', '))
    }

    foreach ($tagMatch in $tagMatches) {
        $tagLine = Get-LineNumber -Text $code -Index $tagMatch.Index

        if ($firstImport.Success -and ($tagMatch.Index -ge $firstImport.Index)) {
            Add-Violation -RelativePath $relativePath -Line $tagLine -Message ("@Tags annotation must appear before the first import (line {0})." -f $firstImportLine)
        }

        $afterTagIndex = $tagMatch.Index + $tagMatch.Length
        $openingMatch = [regex]::Match($code.Substring($afterTagIndex), '\A[\t \r\n]*\(')
        if (-not $openingMatch.Success) {
            Add-Violation -RelativePath $relativePath -Line $tagLine -Message '@Tags must use the @Tags([...]) annotation form.'
            continue
        }

        $openIndex = $afterTagIndex + $openingMatch.Value.LastIndexOf('(')
        $closeIndex = Find-MatchingParen -Text $code -OpenIndex $openIndex
        if ($closeIndex -lt 0) {
            Add-Violation -RelativePath $relativePath -Line $tagLine -Message '@Tags annotation has unbalanced parentheses; expected @Tags([...]).'
            continue
        }

        $annotationBody = $code.Substring($openIndex + 1, $closeIndex - $openIndex - 1).Trim()
        if ((-not $annotationBody.StartsWith('[')) -or (-not $annotationBody.EndsWith(']'))) {
            Add-Violation -RelativePath $relativePath -Line $tagLine -Message '@Tags annotation must contain a list in the form @Tags([...]).'
        }

        $afterAnnotation = $closeIndex + 1
        $remaining = $code.Substring($afterAnnotation)
        $libraryMatch = [regex]::Match($remaining, '\A[\t \r\n]*library\s*;')
        if (-not $libraryMatch.Success) {
            Add-Violation -RelativePath $relativePath -Line $tagLine -Message '@Tags annotation must be followed by an unnamed library; directive before any import.'
            continue
        }

        $libraryKeyword = [regex]::Match($remaining, '\blibrary\b')
        $libraryIndex = $afterAnnotation + $libraryKeyword.Index
        if ($firstImport.Success -and ($libraryIndex -ge $firstImport.Index)) {
            $libraryLine = Get-LineNumber -Text $code -Index $libraryIndex
            Add-Violation -RelativePath $relativePath -Line $libraryLine -Message ("The library; directive following @Tags must occur before the first import (line {0})." -f $firstImportLine)
        }
    }

    # Inspect only direct arguments of test(), testWidgets(), and group().
    # Nested calls are ignored by the depth counters and are checked by their
    # own call match, avoiding duplicate or misleading reports.
    $callMatches = @([regex]::Matches($code, '(?<name>\b(?:testWidgets|test|group))\s*\('))
    foreach ($callMatch in $callMatches) {
        $openIndex = $callMatch.Index + $callMatch.Length - 1
        $closeIndex = Find-MatchingParen -Text $code -OpenIndex $openIndex
        if ($closeIndex -lt 0) {
            continue
        }

        $parenDepth = 0
        $bracketDepth = 0
        $braceDepth = 0
        for ($cursor = $openIndex + 1; $cursor -lt $closeIndex; $cursor++) {
            $character = $code[$cursor]
            if ($character -eq [char] 40) {
                $parenDepth++
                continue
            }
            if ($character -eq [char] 41) {
                $parenDepth--
                continue
            }
            if ($character -eq [char] 91) {
                $bracketDepth++
                continue
            }
            if ($character -eq [char] 93) {
                $bracketDepth--
                continue
            }
            if ($character -eq [char] 123) {
                $braceDepth++
                continue
            }
            if ($character -eq [char] 125) {
                $braceDepth--
                continue
            }

            if (($parenDepth -eq 0) -and
                ($bracketDepth -eq 0) -and
                ($braceDepth -eq 0) -and
                ($character -eq 't') -and
                ($code.Substring($cursor) -match '^\btags\s*:')) {
                $line = Get-LineNumber -Text $code -Index $cursor
                Add-Violation -RelativePath $relativePath -Line $line -Message ("Inline tags: argument found in {0}(...); use a single file-level @Tags([...]) annotation instead." -f $callMatch.Groups['name'].Value)
            }
        }
    }
}

if ($violations.Count -gt 0) {
    Write-Host "Tag placement verification FAILED with $($violations.Count) violation(s)." -ForegroundColor Red
    foreach ($violation in $violations) {
        Write-Host "ERROR: $violation" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Tag placement verification passed.' -ForegroundColor Green
Write-Host "  Test files checked: $($testFiles.Count)"
Write-Host "  Tagged files checked: $taggedFileCount"
Write-Host '  File-level checks: at most one @Tags([...]), annotation before imports, annotation followed by library;'
Write-Host '  Call-level check: no tags: argument in test(), testWidgets(), or group()'
exit 0
