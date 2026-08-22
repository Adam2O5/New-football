[CmdletBinding()]
param(
    [string] $Area,
    [switch] $Fast,
    [string[]] $Tags,
    [string[]] $ExcludeTags,
    [switch] $Coverage,
    [switch] $DryRun
)

$ErrorActionPreference = 'Stop'

$FastExcludedTags = ('slow', 'benchmark') # Mirrors dart_test.yaml presets.fast.exclude_tags.
$ValidAreas = ('match', 'ai', 'market', 'calendar', 'staff', 'messages', 'data', 'ui', 'balance')

function Assert-AreaParameter {
    param(
        [ValidateSet('match', 'ai', 'market', 'calendar', 'staff', 'messages', 'data', 'ui', 'balance')]
        [string] $Area
    )

    return $Area
}

if ($PSBoundParameters.ContainsKey('Area') -and ($ValidAreas -cnotcontains $Area)) {
    Write-Error "Invalid -Area: '$Area'. Allowed: $($ValidAreas -join ', ')." -ErrorAction Continue
    exit 2
}

if ($PSBoundParameters.ContainsKey('Area')) {
    $Area = Assert-AreaParameter -Area $Area
}

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Push-Location -LiteralPath $repoRoot

$args = @('test')

$excludedTags = @()
if ($Fast) {
    $excludedTags += $FastExcludedTags
}
if ($ExcludeTags) {
    $excludedTags += $ExcludeTags
}
$excludedTags = @($excludedTags | Select-Object -Unique)

if ($excludedTags.Count -gt 0) {
    $args += '-x'
    $args += ($excludedTags -join ' || ')
}

$selectedTags = @($Tags | Select-Object -Unique)
if ($selectedTags.Count -gt 0) {
    $args += '-t'
    $args += ($selectedTags -join ' || ')
}

if ($Coverage) {
    $args += '--coverage'
}

if ($PSBoundParameters.ContainsKey('Area')) {
    $areaPath = Join-Path -Path 'test' -ChildPath $Area
    if (-not (Test-Path -LiteralPath $areaPath -PathType Container)) {
        Write-Error "Folder '$areaPath' does not exist." -ErrorAction Continue
        Pop-Location
        exit 2
    }
    $args += $areaPath
}

$displayArgs = @($args | ForEach-Object {
    $argument = [string] $_
    if ($argument -match '\s') {
        '"' + $argument.Replace('"', '\"') + '"'
    }
    else {
        $argument
    }
})
Write-Host "flutter $($displayArgs -join ' ')"

if ($DryRun) {
    Pop-Location
    exit 0
}

& flutter @args
$flutterExitCode = $LASTEXITCODE
Pop-Location
exit $flutterExitCode
