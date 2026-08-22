[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Validates: Requirements 2.2, 3.2, 3.3, 3.4, 3.5
# Property 6: -Fast reproduces presets.fast.exclude_tags.
# Property 7: every valid area maps to exactly one test/<area> path.
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$runnerPath = Join-Path $repoRoot 'scripts\test.ps1'
$configPath = Join-Path $repoRoot 'dart_test.yaml'
$powerShellExecutable = (Get-Command powershell.exe -ErrorAction Stop).Source

function Get-FastExcludedTags {
    $lines = [System.IO.File]::ReadAllLines($configPath)
    $inPresets = $false
    $inFast = $false
    $rawValue = $null

    foreach ($line in $lines) {
        if ($line -match '^\s*presets:\s*(?:#.*)?$') {
            $inPresets = $true
            $inFast = $false
            continue
        }

        if ($inPresets -and ($line -match '^\s*fast:\s*(?:#.*)?$')) {
            $inFast = $true
            continue
        }

        if ($inFast) {
            $excludeMatch = [regex]::Match($line, '^\s*exclude_tags:\s*(?<value>[^#]+?)(?:\s+#.*)?$')
            if ($excludeMatch.Success) {
                $rawValue = $excludeMatch.Groups['value'].Value.Trim()
                break
            }

            if (($line -match '^\S') -and ($line -notmatch '^\s*#')) {
                $inFast = $false
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($rawValue)) {
        throw "Could not read presets.fast.exclude_tags from '$configPath'."
    }

    if ((($rawValue.StartsWith('"')) -and ($rawValue.EndsWith('"'))) -or
        (($rawValue.StartsWith("'")) -and ($rawValue.EndsWith("'")))) {
        $rawValue = $rawValue.Substring(1, $rawValue.Length - 2)
    }

    $tags = @(
        $rawValue -split '\s*\|\|\s*' |
            ForEach-Object { $_.Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )

    if ($tags.Count -eq 0) {
        throw "presets.fast.exclude_tags in '$configPath' did not contain any tags."
    }

    return $tags
}

function Invoke-TestRunnerDryRun {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ArgumentsText
    )

    # Use a child PowerShell process because scripts/test.ps1 intentionally calls
    # exit; invoking it in this Pester process would terminate the test run.
    $escapedRunnerPath = $runnerPath.Replace("'", "''")
    $childCommand = "& '$escapedRunnerPath' $ArgumentsText"
    $output = @(
        & $powerShellExecutable -NoProfile -ExecutionPolicy Bypass -Command $childCommand 2>&1
    )
    $exitCode = $LASTEXITCODE
    $textOutput = @($output | ForEach-Object { [string] $_ })
    $commandLines = @($textOutput | Where-Object { $_ -match '^\s*flutter test(?:\s|$)' })

    if ($commandLines.Count -ne 1) {
        $outputText = if ($textOutput.Count -gt 0) { $textOutput -join [Environment]::NewLine } else { '(no output)' }
        throw "Expected exactly one echoed flutter command for '$ArgumentsText'; found $($commandLines.Count). Output: $outputText"
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = $textOutput
        CommandLine = $commandLines[0].Trim()
    }
}

function Convert-CommandLineToArguments {
    param(
        [Parameter(Mandatory = $true)]
        [string] $CommandLine
    )

    $tokens = New-Object 'System.Collections.Generic.List[string]'
    $matches = [regex]::Matches($CommandLine, '"(?:\\.|[^"])*"|[^\s]+')

    foreach ($match in $matches) {
        $token = $match.Value
        if (($token.Length -ge 2) -and $token.StartsWith('"') -and $token.EndsWith('"')) {
            $token = $token.Substring(1, $token.Length - 2).Replace('\"', '"')
        }

        [void] $tokens.Add($token)
    }

    return $tokens.ToArray()
}

function Assert-ExitCodeIsZero {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject] $Result,
        [Parameter(Mandatory = $true)]
        [string] $Invocation
    )

    if ($Result.ExitCode -ne 0) {
        throw "Expected '$Invocation' to exit 0, got $($Result.ExitCode). Output: $($Result.Output -join [Environment]::NewLine)"
    }
}

function Assert-ArgumentsEqual {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Actual,
        [Parameter(Mandatory = $true)]
        [string[]] $Expected,
        [Parameter(Mandatory = $true)]
        [string] $Invocation
    )

    if ($Actual.Count -ne $Expected.Count) {
        throw "Unexpected argument count for '$Invocation'. Expected [$($Expected -join ', ')], actual [$($Actual -join ', ')]."
    }

    for ($index = 0; $index -lt $Expected.Count; $index++) {
        if ($Actual[$index] -cne $Expected[$index]) {
            throw "Unexpected argument at index $index for '$Invocation'. Expected '$($Expected[$index])', actual '$($Actual[$index])'. Full command: $($Actual -join ' | ')"
        }
    }
}

function Get-ArgumentValue {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Arguments,
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Parameter(Mandatory = $true)]
        [string] $Invocation
    )

    $index = [Array]::IndexOf($Arguments, $Name)
    if ($index -lt 0) {
        throw "Expected argument '$Name' for '$Invocation'. Actual arguments: [$($Arguments -join ', ')]."
    }

    if (($index + 1) -ge $Arguments.Count) {
        throw "Argument '$Name' has no value for '$Invocation'."
    }

    return $Arguments[$index + 1]
}

Describe 'scripts/test.ps1 -DryRun command construction' {
    It 'Property 6: uses exactly presets.fast.exclude_tags for -Fast' {
        $fastExcludedTags = @(Get-FastExcludedTags)
        $expectedExpression = $fastExcludedTags -join ' || '
        $invocation = '-Fast -DryRun'
        $result = Invoke-TestRunnerDryRun -ArgumentsText $invocation
        Assert-ExitCodeIsZero -Result $result -Invocation $invocation

        $arguments = @(Convert-CommandLineToArguments -CommandLine $result.CommandLine)
        Assert-ArgumentsEqual -Actual $arguments -Expected @('flutter', 'test', '-x', $expectedExpression) -Invocation $invocation

        $actualExcludedTags = @((Get-ArgumentValue -Arguments $arguments -Name '-x' -Invocation $invocation) -split '\s*\|\|\s*' | ForEach-Object { $_.Trim() })
        $actualExcludedTags = @($actualExcludedTags | Sort-Object -Unique)
        $expectedExcludedTags = @($fastExcludedTags | Sort-Object -Unique)
        Assert-ArgumentsEqual -Actual $actualExcludedTags -Expected $expectedExcludedTags -Invocation $invocation
    }

    It 'Property 7: maps every valid area to one path and preserves it with -Fast' {
        $domains = @('match', 'ai', 'market', 'calendar', 'staff', 'messages', 'data', 'ui', 'balance')
        $fastExcludedTags = @(Get-FastExcludedTags)
        $expectedExpression = $fastExcludedTags -join ' || '

        foreach ($domain in $domains) {
            $expectedAreaPath = Join-Path -Path 'test' -ChildPath $domain

            $plainInvocation = "-Area $domain -DryRun"
            $plainResult = Invoke-TestRunnerDryRun -ArgumentsText $plainInvocation
            Assert-ExitCodeIsZero -Result $plainResult -Invocation $plainInvocation
            $plainArguments = @(Convert-CommandLineToArguments -CommandLine $plainResult.CommandLine)
            Assert-ArgumentsEqual -Actual $plainArguments -Expected @('flutter', 'test', $expectedAreaPath) -Invocation $plainInvocation

            $plainPaths = @($plainArguments | Where-Object { $_ -match '^test[/\\]' })
            $normalizedPlainPath = if ($plainPaths.Count -eq 1) { $plainPaths[0] -replace '\\', '/' } else { $null }
            if (($plainPaths.Count -ne 1) -or ($normalizedPlainPath -cne "test/$domain")) {
                throw "Expected exactly one path test/$domain for '$plainInvocation'; actual paths: [$($plainPaths -join ', ')]."
            }

            $fastInvocation = "-Area $domain -Fast -DryRun"
            $fastResult = Invoke-TestRunnerDryRun -ArgumentsText $fastInvocation
            Assert-ExitCodeIsZero -Result $fastResult -Invocation $fastInvocation
            $fastArguments = @(Convert-CommandLineToArguments -CommandLine $fastResult.CommandLine)
            Assert-ArgumentsEqual -Actual $fastArguments -Expected @('flutter', 'test', '-x', $expectedExpression, $expectedAreaPath) -Invocation $fastInvocation

            $fastPaths = @($fastArguments | Where-Object { $_ -match '^test[/\\]' })
            $normalizedFastPath = if ($fastPaths.Count -eq 1) { $fastPaths[0] -replace '\\', '/' } else { $null }
            if (($fastPaths.Count -ne 1) -or ($normalizedFastPath -cne "test/$domain")) {
                throw "Expected exactly one path test/$domain for '$fastInvocation'; actual paths: [$($fastPaths -join ', ')]."
            }
        }
    }

    It 'builds tag, exclusion, and coverage options together with the documented ordering' {
        $fastExcludedTags = @(Get-FastExcludedTags)
        $fastExpression = $fastExcludedTags -join ' || '
        $cases = @(
            [pscustomobject]@{
                Invocation = '-Tags ui -DryRun'
                Expected = @('flutter', 'test', '-t', 'ui')
            },
            [pscustomobject]@{
                Invocation = '-Tags ui,property -DryRun'
                Expected = @('flutter', 'test', '-t', 'ui || property')
            },
            [pscustomobject]@{
                Invocation = '-Fast -ExcludeTags ui -DryRun'
                Expected = @('flutter', 'test', '-x', "$fastExpression || ui")
            },
            [pscustomobject]@{
                Invocation = '-Area ai -Coverage -DryRun'
                Expected = @('flutter', 'test', '--coverage', (Join-Path -Path 'test' -ChildPath 'ai'))
            }
        )

        foreach ($case in $cases) {
            $result = Invoke-TestRunnerDryRun -ArgumentsText $case.Invocation
            Assert-ExitCodeIsZero -Result $result -Invocation $case.Invocation
            $arguments = @(Convert-CommandLineToArguments -CommandLine $result.CommandLine)
            Assert-ArgumentsEqual -Actual $arguments -Expected $case.Expected -Invocation $case.Invocation
        }
    }
}
