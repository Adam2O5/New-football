[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Property 4: every file-level tag used by test/** must be declared in
# dart_test.yaml, and dart_test.yaml must contain exactly this tag set.
$expectedDeclaredTags = @(
    'slow',
    'ui',
    'property',
    'integration',
    'benchmark',
    'ai'
)
$expectedTaggedFileCount = 51
$violations = New-Object 'System.Collections.Generic.List[string]'

function Add-Violation {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    [void] $violations.Add($Message)
}

function Skip-Trivia {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Text,
        [Parameter(Mandatory = $true)]
        [int] $Start
    )

    $index = $Start
    while ($index -lt $Text.Length) {
        if ([char]::IsWhiteSpace($Text[$index])) {
            $index++
            continue
        }

        if (($Text[$index] -eq '/') -and (($index + 1) -lt $Text.Length) -and ($Text[$index + 1] -eq '/')) {
            $newline = $Text.IndexOf("`n", $index + 2)
            if ($newline -lt 0) {
                return $Text.Length
            }

            $index = $newline + 1
            continue
        }

        if (($Text[$index] -eq '/') -and (($index + 1) -lt $Text.Length) -and ($Text[$index + 1] -eq '*')) {
            $commentEnd = $Text.IndexOf('*/', $index + 2)
            if ($commentEnd -lt 0) {
                return $Text.Length
            }

            $index = $commentEnd + 2
            continue
        }

        break
    }

    return $index
}

function Find-StringEnd {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Text,
        [Parameter(Mandatory = $true)]
        [int] $Start
    )

    if (($Start -lt 0) -or ($Start -ge $Text.Length) -or (($Text[$Start] -ne "'") -and ($Text[$Start] -ne '"'))) {
        return -1
    }

    $quote = [string] $Text[$Start]
    $tripleDelimiter = $quote + $quote + $quote
    $isTriple = (($Start + 3) -le $Text.Length) -and ($Text.Substring($Start, 3) -eq $tripleDelimiter)
    $delimiterLength = if ($isTriple) { 3 } else { 1 }
    $index = $Start + $delimiterLength

    while ($index -lt $Text.Length) {
        if ($isTriple -and (($index + 3) -le $Text.Length) -and ($Text.Substring($index, 3) -eq $tripleDelimiter)) {
            return $index + 3
        }

        if ((-not $isTriple) -and ($Text[$index] -eq $Text[$Start])) {
            return $index + 1
        }

        if ($Text[$index] -eq '\') {
            # Skip an escaped character so an escaped quote does not terminate
            # the string. This is sufficient for locating annotation syntax.
            $index += 2
            continue
        }

        $index++
    }

    return -1
}

function Read-TagLiteral {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Text,
        [Parameter(Mandatory = $true)]
        [int] $Start
    )

    if (($Start -ge $Text.Length) -or (($Text[$Start] -ne "'") -and ($Text[$Start] -ne '"'))) {
        return [pscustomobject]@{
            Success = $false
            Value = $null
            NextIndex = $Start
            Error = 'Expected a quoted tag string.'
        }
    }

    $quote = [string] $Text[$Start]
    $tripleDelimiter = $quote + $quote + $quote
    if ((($Start + 3) -le $Text.Length) -and ($Text.Substring($Start, 3) -eq $tripleDelimiter)) {
        return [pscustomobject]@{
            Success = $false
            Value = $null
            NextIndex = $Text.Length
            Error = 'Triple-quoted strings are not valid tag literals.'
        }
    }

    $end = Find-StringEnd -Text $Text -Start $Start
    if ($end -lt 0) {
        return [pscustomobject]@{
            Success = $false
            Value = $null
            NextIndex = $Text.Length
            Error = 'Unterminated quoted tag string.'
        }
    }

    $valueLength = $end - $Start - 2
    $value = if ($valueLength -gt 0) { $Text.Substring($Start + 1, $valueLength) } else { '' }
    if ([string]::IsNullOrWhiteSpace($value)) {
        return [pscustomobject]@{
            Success = $false
            Value = $value
            NextIndex = $end
            Error = 'Tag literals must not be empty.'
        }
    }

    return [pscustomobject]@{
        Success = $true
        Value = $value
        NextIndex = $end
        Error = $null
    }
}

function Parse-TagList {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Body
    )

    $index = Skip-Trivia -Text $Body -Start 0
    if (($index -ge $Body.Length) -or ($Body[$index] -ne '[')) {
        return [pscustomobject]@{
            Success = $false
            Tags = @()
            Error = 'The @Tags annotation argument must be a list, for example @Tags([''ui'']).'
        }
    }

    $index++
    $tags = New-Object 'System.Collections.Generic.List[string]'

    while ($true) {
        $index = Skip-Trivia -Text $Body -Start $index
        if ($index -ge $Body.Length) {
            return [pscustomobject]@{
                Success = $false
                Tags = @()
                Error = 'The @Tags list is missing its closing bracket.'
            }
        }

        if ($Body[$index] -eq ']') {
            $index++
            $index = Skip-Trivia -Text $Body -Start $index
            if ($index -ne $Body.Length) {
                return [pscustomobject]@{
                    Success = $false
                    Tags = @()
                    Error = 'Unexpected content follows the @Tags list.'
                }
            }

            return [pscustomobject]@{
                Success = $true
                Tags = $tags.ToArray()
                Error = $null
            }
        }

        $literal = Read-TagLiteral -Text $Body -Start $index
        if (-not $literal.Success) {
            return [pscustomobject]@{
                Success = $false
                Tags = @()
                Error = $literal.Error
            }
        }

        [void] $tags.Add([string] $literal.Value)
        $index = Skip-Trivia -Text $Body -Start $literal.NextIndex
        if ($index -ge $Body.Length) {
            return [pscustomobject]@{
                Success = $false
                Tags = @()
                Error = 'The @Tags list is missing its closing bracket.'
            }
        }

        if ($Body[$index] -eq ',') {
            $index++
            continue
        }

        if ($Body[$index] -ne ']') {
            return [pscustomobject]@{
                Success = $false
                Tags = @()
                Error = 'Expected a comma or closing bracket after a tag literal.'
            }
        }
    }
}

function Find-BalancedAnnotation {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Text,
        [Parameter(Mandatory = $true)]
        [int] $OpenIndex
    )

    $depth = 1
    $index = $OpenIndex + 1
    while ($index -lt $Text.Length) {
        if (($Text[$index] -eq '/') -and (($index + 1) -lt $Text.Length) -and ($Text[$index + 1] -eq '/')) {
            $newline = $Text.IndexOf("`n", $index + 2)
            $index = if ($newline -lt 0) { $Text.Length } else { $newline + 1 }
            continue
        }

        if (($Text[$index] -eq '/') -and (($index + 1) -lt $Text.Length) -and ($Text[$index + 1] -eq '*')) {
            $commentEnd = $Text.IndexOf('*/', $index + 2)
            if ($commentEnd -lt 0) {
                return [pscustomobject]@{
                    Success = $false
                    EndIndex = -1
                    Error = 'Unterminated block comment inside @Tags annotation.'
                }
            }

            $index = $commentEnd + 2
            continue
        }

        if (($Text[$index] -eq "'") -or ($Text[$index] -eq '"')) {
            $stringEnd = Find-StringEnd -Text $Text -Start $index
            if ($stringEnd -lt 0) {
                return [pscustomobject]@{
                    Success = $false
                    EndIndex = -1
                    Error = 'Unterminated string inside @Tags annotation.'
                }
            }

            $index = $stringEnd
            continue
        }

        if ($Text[$index] -eq '(') {
            $depth++
        }
        elseif ($Text[$index] -eq ')') {
            $depth--
            if ($depth -eq 0) {
                return [pscustomobject]@{
                    Success = $true
                    EndIndex = $index
                    Error = $null
                }
            }
        }

        $index++
    }

    return [pscustomobject]@{
        Success = $false
        EndIndex = -1
        Error = 'The @Tags annotation is missing its closing parenthesis.'
    }
}

function Get-TagAnnotations {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Text
    )

    $annotations = New-Object 'System.Collections.Generic.List[object]'
    $index = 0
    while ($index -lt $Text.Length) {
        if (($Text[$index] -eq '/') -and (($index + 1) -lt $Text.Length) -and ($Text[$index + 1] -eq '/')) {
            $newline = $Text.IndexOf("`n", $index + 2)
            $index = if ($newline -lt 0) { $Text.Length } else { $newline + 1 }
            continue
        }

        if (($Text[$index] -eq '/') -and (($index + 1) -lt $Text.Length) -and ($Text[$index + 1] -eq '*')) {
            $commentEnd = $Text.IndexOf('*/', $index + 2)
            $index = if ($commentEnd -lt 0) { $Text.Length } else { $commentEnd + 2 }
            continue
        }

        if (($Text[$index] -eq "'") -or ($Text[$index] -eq '"')) {
            $stringEnd = Find-StringEnd -Text $Text -Start $index
            $index = if ($stringEnd -lt 0) { $Text.Length } else { $stringEnd }
            continue
        }

        $isTagsToken = ($index + 5 -le $Text.Length) -and ($Text.Substring($index, 5) -eq '@Tags')
        if ($isTagsToken) {
            $afterToken = $index + 5
            $isIdentifierContinuation = ($afterToken -lt $Text.Length) -and ($Text[$afterToken] -match '[A-Za-z0-9_$]')
            if (-not $isIdentifierContinuation) {
                $openIndex = Skip-Trivia -Text $Text -Start $afterToken
                if (($openIndex -ge $Text.Length) -or ($Text[$openIndex] -ne '(')) {
                    [void] $annotations.Add([pscustomobject]@{
                        IsMalformed = $true
                        Tags = @()
                        Error = '@Tags must be followed by a parenthesized tag list.'
                    })
                    $index = $afterToken
                    continue
                }

                $balanced = Find-BalancedAnnotation -Text $Text -OpenIndex $openIndex
                if (-not $balanced.Success) {
                    [void] $annotations.Add([pscustomobject]@{
                        IsMalformed = $true
                        Tags = @()
                        Error = $balanced.Error
                    })
                    $index = $Text.Length
                    continue
                }

                $bodyLength = $balanced.EndIndex - $openIndex - 1
                $body = if ($bodyLength -gt 0) { $Text.Substring($openIndex + 1, $bodyLength) } else { '' }
                $parsed = Parse-TagList -Body $body
                if (-not $parsed.Success) {
                    [void] $annotations.Add([pscustomobject]@{
                        IsMalformed = $true
                        Tags = @()
                        Error = $parsed.Error
                    })
                }
                else {
                    [void] $annotations.Add([pscustomobject]@{
                        IsMalformed = $false
                        Tags = @($parsed.Tags)
                        Error = $null
                    })
                }

                $index = $balanced.EndIndex + 1
                continue
            }
        }

        $index++
    }

    return $annotations.ToArray()
}

function Parse-DeclaredTags {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Text
    )

    $tags = New-Object 'System.Collections.Generic.List[string]'
    $errors = New-Object 'System.Collections.Generic.List[string]'
    $inTagsSection = $false
    $tagHeaderSeen = $false
    $lineNumber = 0

    foreach ($line in ($Text -split "`r?`n")) {
        $lineNumber++

        if ($line -match '^\s*tags\s*:\s*(?:#.*)?$') {
            if ($tagHeaderSeen) {
                [void] $errors.Add("line ${lineNumber}: duplicate tags section.")
            }

            $tagHeaderSeen = $true
            $inTagsSection = $true
            continue
        }

        if ($inTagsSection -and ($line -match '^\s*presets\s*:')) {
            $inTagsSection = $false
            continue
        }

        if (-not $inTagsSection) {
            continue
        }

        if ([string]::IsNullOrWhiteSpace($line) -or ($line -match '^\s*#')) {
            continue
        }

        $tagMatch = [regex]::Match($line, '^\s{2,}(?<name>[A-Za-z][A-Za-z0-9_-]*)\s*:')
        if (-not $tagMatch.Success) {
            [void] $errors.Add("line ${lineNumber}: malformed tag declaration '$line'.")
            continue
        }

        $name = $tagMatch.Groups['name'].Value
        if ($tags -ccontains $name) {
            [void] $errors.Add("line ${lineNumber}: duplicate declared tag '$name'.")
            continue
        }

        [void] $tags.Add($name)
    }

    return [pscustomobject]@{
        HeaderSeen = $tagHeaderSeen
        Tags = $tags.ToArray()
        Errors = $errors.ToArray()
    }
}

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$configPath = Join-Path $repoRoot 'dart_test.yaml'
$testRoot = Join-Path $repoRoot 'test'
$declaredTags = @()

if (-not (Test-Path -LiteralPath $configPath -PathType Leaf)) {
    Add-Violation "Configuration file does not exist: '$configPath'."
}
else {
    $configText = Get-Content -LiteralPath $configPath -Raw
    $configResult = Parse-DeclaredTags -Text $configText
    $declaredTags = @($configResult.Tags)

    foreach ($error in @($configResult.Errors)) {
        Add-Violation "dart_test.yaml: $error"
    }

    if (-not $configResult.HeaderSeen) {
        Add-Violation "dart_test.yaml does not contain a top-level 'tags:' section."
    }
}

$missingDeclaredTags = @($expectedDeclaredTags | Where-Object { $declaredTags -cnotcontains $_ })
$unexpectedDeclaredTags = @($declaredTags | Where-Object { $expectedDeclaredTags -cnotcontains $_ })
if ($missingDeclaredTags.Count -gt 0) {
    Add-Violation "dart_test.yaml is missing declared tag(s): $($missingDeclaredTags -join ', ')."
}
if ($unexpectedDeclaredTags.Count -gt 0) {
    Add-Violation "dart_test.yaml contains unexpected declared tag(s): $($unexpectedDeclaredTags -join ', ')."
}

$taggedFiles = New-Object 'System.Collections.Generic.List[string]'
$observedTags = New-Object 'System.Collections.Generic.List[string]'
$tagUsage = @{}

$sourceFiles = @()
if (-not (Test-Path -LiteralPath $testRoot -PathType Container)) {
    Add-Violation "Test root does not exist: '$testRoot'."
}
else {
    # Scan every Dart source below test/, not just the currently known domain
    # folders, so a new tagged file cannot bypass this check.
    $sourceFiles = @(Get-ChildItem -LiteralPath $testRoot -Recurse -File -Filter '*.dart' -Force)
}

foreach ($file in $sourceFiles) {
    $content = Get-Content -LiteralPath $file.FullName -Raw
    $annotations = @(Get-TagAnnotations -Text $content)
    if ($annotations.Count -eq 0) {
        continue
    }

    $relativePath = $file.FullName.Substring($repoRoot.Length) -replace '^[\\/]+', ''
    $relativePath = $relativePath -replace '\\', '/'
    [void] $taggedFiles.Add($relativePath)

    foreach ($annotation in $annotations) {
        if ($annotation.IsMalformed) {
            Add-Violation "Malformed @Tags annotation in '$relativePath': $($annotation.Error)"
            continue
        }

        foreach ($tag in @($annotation.Tags)) {
            if ($observedTags -cnotcontains $tag) {
                [void] $observedTags.Add($tag)
            }

            if ($tagUsage.ContainsKey($tag)) {
                $tagUsage[$tag]++
            }
            else {
                $tagUsage[$tag] = 1
            }

            if ($declaredTags -cnotcontains $tag) {
                Add-Violation "Unknown tag '$tag' in '$relativePath'; it is not declared in dart_test.yaml."
            }
        }
    }
}

if ($taggedFiles.Count -ne $expectedTaggedFileCount) {
    Add-Violation "Expected exactly $expectedTaggedFileCount tagged files under test/**; found $($taggedFiles.Count)."
}

$unknownObservedTags = @($observedTags | Where-Object { $declaredTags -cnotcontains $_ })
if ($unknownObservedTags.Count -gt 0) {
    Add-Violation "Annotation tag set is not a subset of dart_test.yaml declarations; unknown tag(s): $($unknownObservedTags -join ', ')."
}

$declaredDisplay = if ($declaredTags.Count -gt 0) { $declaredTags -join ', ' } else { '(none)' }
$observedDisplay = if ($observedTags.Count -gt 0) { $observedTags -join ', ' } else { '(none)' }

if ($violations.Count -gt 0) {
    Write-Host "Tag verification FAILED with $($violations.Count) violation(s)." -ForegroundColor Red
    Write-Host "  Declared tags: {$declaredDisplay}"
    Write-Host "  Annotation tags: {$observedDisplay}"
    Write-Host "  Tagged files: $($taggedFiles.Count) (expected $expectedTaggedFileCount)"
    foreach ($violation in $violations) {
        Write-Host "ERROR: $violation" -ForegroundColor Red
    }
    exit 1
}

Write-Host 'Tag verification passed.' -ForegroundColor Green
Write-Host "  dart_test.yaml declared exactly: {$declaredDisplay}"
Write-Host "  Annotation tag set: {$observedDisplay}"
Write-Host "  Tagged files checked: $($taggedFiles.Count)"
Write-Host '  Unknown tags: none'
if ($tagUsage.Count -gt 0) {
    $usageDisplay = @($tagUsage.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value) file(s)" }) -join ', '
    Write-Host "  Tag usage: $usageDisplay"
}
exit 0
