[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Validates: Requirements 3.7 and 3.8
# Property 8: every representative invalid Area is rejected with the complete
# allowed-value list.
$script:task93RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$script:task93RunnerPath = Join-Path $script:task93RepoRoot 'scripts\test.ps1'
$script:task93AllowedAreas = @(
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

function Get-Task93PowerShellPath {
    $command = Get-Command powershell.exe -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source
    }

    $command = Get-Command pwsh.exe -ErrorAction SilentlyContinue
    if ($null -ne $command) {
        return $command.Source
    }

    throw 'Unable to locate PowerShell for runner exit-code tests.'
}

function ConvertTo-Task93ProcessArgument {
    param(
        [Parameter()]
        [AllowEmptyString()]
        [string] $Argument
    )

    if ($null -eq $Argument) {
        $Argument = ''
    }

    # Quote every argument and escape backslashes before embedded quotes and at
    # the end, preserving empty and whitespace-only -Area values in Windows PS.
    $builder = New-Object System.Text.StringBuilder
    [void] $builder.Append('"')
    $backslashCount = 0
    foreach ($character in $Argument.ToCharArray()) {
        if ($character -eq '\\') {
            $backslashCount++
            continue
        }

        if ($character -eq '"') {
            for ($index = 0; $index -lt (($backslashCount * 2) + 1); $index++) {
                [void] $builder.Append('\\')
            }
            [void] $builder.Append('"')
            $backslashCount = 0
            continue
        }

        for ($index = 0; $index -lt $backslashCount; $index++) {
            [void] $builder.Append('\\')
        }
        [void] $builder.Append($character)
        $backslashCount = 0
    }

    for ($index = 0; $index -lt ($backslashCount * 2); $index++) {
        [void] $builder.Append('\\')
    }
    [void] $builder.Append('"')
    return $builder.ToString()
}

function Invoke-Task93Runner {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ScriptPath,

        [Parameter()]
        [AllowEmptyCollection()]
        [string[]] $RunnerArguments = @()
    )

    $processArguments = @(
        '-NoLogo',
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        $ScriptPath
    )
    if ($null -ne $RunnerArguments) {
        $processArguments += $RunnerArguments
    }

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = Get-Task93PowerShellPath
    $startInfo.Arguments = (@($processArguments | ForEach-Object {
        ConvertTo-Task93ProcessArgument -Argument ([string] $_)
    }) -join ' ')
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) {
            throw "Unable to start child PowerShell for '$ScriptPath'."
        }

        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()

        return [pscustomobject]@{
            ExitCode = $process.ExitCode
            Output = $stdoutTask.Result + [Environment]::NewLine + $stderrTask.Result
        }
    }
    finally {
        $process.Dispose()
    }
}

$allowedListPattern = [regex]::Escape('Allowed:' + ($script:task93AllowedAreas -join ','))

Describe 'scripts/test.ps1 validation and exit codes' {
    BeforeAll {
        if (-not (Test-Path -LiteralPath $script:task93RunnerPath -PathType Leaf)) {
            throw "Runner script does not exist: '$script:task93RunnerPath'."
        }
    }

    It 'Property 8: rejects empty, whitespace, mixed-case, and random Area values with the complete allowed list' {
        $invalidAreas = @('', ' ', 'Market', 'nope')

        foreach ($invalidArea in $invalidAreas) {
            $result = Invoke-Task93Runner -ScriptPath $script:task93RunnerPath -RunnerArguments @('-Area', $invalidArea)
            $label = if ($invalidArea.Length -eq 0) { '<empty>' } elseif ($invalidArea -match '^\s+$') { '<whitespace>' } else { $invalidArea }

            $result.ExitCode | Should Not Be 0
            $normalizedOutput = $result.Output -replace '\s+', ''
            $normalizedOutput | Should Match $allowedListPattern
        }
    }

    It 'returns a nonzero exit code for a deliberately failing temporary test and removes the fixture' {
        $marketDirectory = Join-Path $script:task93RepoRoot 'test\market'
        $temporaryFailurePath = Join-Path $marketDirectory ('task93_runner_failure_{0}_test.dart' -f ([guid]::NewGuid().ToString('N')))
        $marker = 'TASK93_TEMP_FAILURE_MARKER'
        $temporaryFailureSource = @"
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('task 9.3 deliberate runner failure', () {
    print('$marker');
    expect(false, isTrue);
  });
}
"@

        try {
            [System.IO.File]::WriteAllText(
                $temporaryFailurePath,
                $temporaryFailureSource,
                (New-Object System.Text.UTF8Encoding($false))
            )

            $result = Invoke-Task93Runner -ScriptPath $script:task93RunnerPath -RunnerArguments @('-Area', 'market')
            $result.ExitCode | Should Not Be 0
            $result.Output | Should Match ([regex]::Escape($marker))
        }
        finally {
            if (Test-Path -LiteralPath $temporaryFailurePath -PathType Leaf) {
                Remove-Item -LiteralPath $temporaryFailurePath -Force
            }
        }

        Test-Path -LiteralPath $temporaryFailurePath | Should Be $false
    }

    It 'runs correctly when the repository path contains spaces' {
        $spaceRepositoryRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('new football runner test {0}' -f ([guid]::NewGuid().ToString('N')))
        $spaceRunnerPath = Join-Path $spaceRepositoryRoot 'scripts\test.ps1'
        $spaceMarketDirectory = Join-Path $spaceRepositoryRoot 'test\market'

        try {
            New-Item -ItemType Directory -Path (Split-Path -Parent $spaceRunnerPath) -Force | Out-Null
            New-Item -ItemType Directory -Path $spaceMarketDirectory -Force | Out-Null
            Copy-Item -LiteralPath $script:task93RunnerPath -Destination $spaceRunnerPath -Force

            $result = Invoke-Task93Runner -ScriptPath $spaceRunnerPath -RunnerArguments @('-Area', 'market', '-DryRun')
            $result.ExitCode | Should Be 0
            $result.Output | Should Match '(?m)^flutter\s+test\s+test[/\\]market\s*$'
        }
        finally {
            if (Test-Path -LiteralPath $spaceRepositoryRoot) {
                Remove-Item -LiteralPath $spaceRepositoryRoot -Recurse -Force
            }
        }

        Test-Path -LiteralPath $spaceRepositoryRoot | Should Be $false
    }
}
