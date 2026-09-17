[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$installer = Join-Path $PSScriptRoot 'install.ps1'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("UEGameStudio-InstallTest-" + [guid]::NewGuid().ToString('N'))
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

function Assert-True {
    param(
        [Parameter(Mandatory = $true)][bool]$Condition,
        [Parameter(Mandatory = $true)][string]$Message
    )
    if (-not $Condition) {
        throw "ASSERTION FAILED: $Message"
    }
}

try {
    New-Item -ItemType Directory -Path $testRoot | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $testRoot 'InstallTest.uproject'), '{"FileVersion":3}', $utf8NoBom)
    [System.IO.File]::WriteAllText((Join-Path $testRoot 'AGENTS.md'), "# Project-owned instructions`n", $utf8NoBom)

    $existingConfig = @'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "example": {
      "name": "Preserve Me"
    }
  },
  "instructions": [
    "PROJECT.md"
  ]
}
'@
    [System.IO.File]::WriteAllText((Join-Path $testRoot 'opencode.json'), $existingConfig, $utf8NoBom)

    & $installer -TargetProject $testRoot -SkillsVersion 'ue5.6' -NoConfigBackup

    $installedAgents = @(Get-ChildItem -LiteralPath (Join-Path $testRoot '.opencode\agent') -Recurse -Filter '*.md' -File)
    Assert-True ($installedAgents.Count -eq 31) "Expected 31 installed agents, found $($installedAgents.Count)."
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $testRoot '.opencode\agent\_template.md'))) 'Template must not be installed.'
    Assert-True (Test-Path -LiteralPath (Join-Path $testRoot 'UEGameStudio\AGENTS.md')) 'UEGameStudio/AGENTS.md was not installed.'
    Assert-True (Test-Path -LiteralPath (Join-Path $testRoot 'UEGameStudio\docs\formal-project-validation.md')) 'Validation method was not installed.'
    @('editor-actor-subsystem', 'data-table-function-library') | ForEach-Object {
        $skillRoot = Join-Path $testRoot ".opencode\skills\ue5.6\$_"
        Assert-True (Test-Path -LiteralPath (Join-Path $skillRoot 'SKILL.md')) "SKILL.md of $_ (ue5.6) was not installed."
        Assert-True (Test-Path -LiteralPath (Join-Path $skillRoot 'docs\overview.md')) "docs/overview.md of $_ (ue5.6) was not installed."
    }
    Assert-True ((Get-Content -LiteralPath (Join-Path $testRoot 'AGENTS.md') -Raw) -eq "# Project-owned instructions`n") 'Project-owned AGENTS.md was modified.'

    $config = Get-Content -LiteralPath (Join-Path $testRoot 'opencode.json') -Raw | ConvertFrom-Json
    Assert-True ($config.provider.example.name -eq 'Preserve Me') 'Existing opencode.json properties were not preserved.'
    Assert-True (@($config.instructions | Where-Object { $_ -eq 'PROJECT.md' }).Count -eq 1) 'Existing instruction was lost or duplicated.'
    Assert-True (@($config.instructions | Where-Object { $_ -eq 'AGENTS.md' }).Count -eq 0) 'Installer must not inject project AGENTS.md into instructions.'
    Assert-True (@($config.instructions | Where-Object { $_ -eq 'UEGameStudio/AGENTS.md' }).Count -eq 1) 'UEGameStudio/AGENTS.md must appear exactly once.'
    Assert-True ($config.subagent_depth -eq 2) 'Existing config must receive subagent_depth = 2 so orchestration-director can delegate.'

    & $installer -TargetProject $testRoot -SkillsVersion 'ue5.6' -NoConfigBackup

    $configAfterSecondRun = Get-Content -LiteralPath (Join-Path $testRoot 'opencode.json') -Raw | ConvertFrom-Json
    Assert-True (@($configAfterSecondRun.instructions | Where-Object { $_ -eq 'AGENTS.md' }).Count -eq 0) 'Second run injected project AGENTS.md.'
    Assert-True (@($configAfterSecondRun.instructions | Where-Object { $_ -eq 'UEGameStudio/AGENTS.md' }).Count -eq 1) 'Second run duplicated UEGameStudio/AGENTS.md.'
    Assert-True ($configAfterSecondRun.subagent_depth -eq 2) 'Second run must not change or duplicate subagent_depth.'

    $missingVersionRoot = Join-Path $testRoot 'MissingVersionProject'
    New-Item -ItemType Directory -Path $missingVersionRoot | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $missingVersionRoot 'MissingVersion.uproject'), '{"FileVersion":3}', $utf8NoBom)
    $badVersionError = $null
    try {
        & $installer -TargetProject $missingVersionRoot -SkillsVersion 'ue9.9' -NoConfigBackup -ErrorAction Stop
        throw 'Expected installer to fail for a nonexistent skills version.'
    }
    catch {
        $badVersionError = $_.Exception.Message
    }
    Assert-True ($null -ne $badVersionError) 'Installer must fail for a nonexistent skills version.'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $missingVersionRoot '.opencode\skills'))) 'Skills must not be installed for a nonexistent version.'

    $freshRoot = Join-Path $testRoot 'FreshProject'
    New-Item -ItemType Directory -Path $freshRoot | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $freshRoot 'FreshProject.uproject'), '{"FileVersion":3}', $utf8NoBom)
    & $installer -TargetProject $freshRoot -SkillsVersion 'ue5.6' -NoConfigBackup

    $freshConfig = Get-Content -LiteralPath (Join-Path $freshRoot 'opencode.json') -Raw | ConvertFrom-Json
    Assert-True (@($freshConfig.instructions).Count -eq 1) 'Fresh config must contain only the UEGameStudio instruction.'
    Assert-True ($freshConfig.instructions[0] -eq 'UEGameStudio/AGENTS.md') 'Fresh config must add UEGameStudio/AGENTS.md.'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $freshRoot 'AGENTS.md'))) 'Installer must not create project-owned AGENTS.md.'
    Assert-True ($freshConfig.subagent_depth -eq 2) 'Fresh config must set subagent_depth = 2.'

    $customDepthRoot = Join-Path $testRoot 'CustomDepthProject'
    New-Item -ItemType Directory -Path $customDepthRoot | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $customDepthRoot 'CustomDepth.uproject'), '{"FileVersion":3}', $utf8NoBom)
    [System.IO.File]::WriteAllText((Join-Path $customDepthRoot 'opencode.json'), '{ "subagent_depth": 5 }', $utf8NoBom)
    & $installer -TargetProject $customDepthRoot -SkillsVersion 'ue5.6' -NoConfigBackup

    $customDepthConfig = Get-Content -LiteralPath (Join-Path $customDepthRoot 'opencode.json') -Raw | ConvertFrom-Json
    Assert-True ($customDepthConfig.subagent_depth -eq 5) 'Installer must not lower an existing larger subagent_depth.'

    $invalidDepthRoot = Join-Path $testRoot 'InvalidDepthProject'
    New-Item -ItemType Directory -Path $invalidDepthRoot | Out-Null
    [System.IO.File]::WriteAllText((Join-Path $invalidDepthRoot 'InvalidDepth.uproject'), '{"FileVersion":3}', $utf8NoBom)
    [System.IO.File]::WriteAllText((Join-Path $invalidDepthRoot 'opencode.json'), '{ "subagent_depth": "two" }', $utf8NoBom)
    $invalidDepthError = $null
    try {
        & $installer -TargetProject $invalidDepthRoot -SkillsVersion 'ue5.6' -NoConfigBackup -ErrorAction Stop
        throw 'Expected installer to fail for a non-integer subagent_depth.'
    }
    catch {
        $invalidDepthError = $_.Exception.Message
    }
    Assert-True ($null -ne $invalidDepthError) 'Installer must fail for a non-integer subagent_depth.'
    Assert-True ((Get-Content -LiteralPath (Join-Path $invalidDepthRoot 'opencode.json') -Raw) -match '"two"') 'A non-integer subagent_depth config must be left unmodified.'

    Write-Host 'Installer tests passed: automatic root AGENTS separation, 31-agent copy, ue5.6 skills copy, version enforcement, UEGameStudio-only merge, fresh config, subagent_depth delegation gate, and idempotence.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) {
        $resolvedTestRoot = (Resolve-Path -LiteralPath $testRoot).Path
        $separator = [System.IO.Path]::DirectorySeparatorChar
        $expectedPrefix = [System.IO.Path]::GetTempPath().TrimEnd($separator) + $separator + 'UEGameStudio-InstallTest-'
        if ($resolvedTestRoot.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedTestRoot -Recurse -Force
        }
        else {
            Write-Warning "Refusing to remove unexpected test path: $resolvedTestRoot"
        }
    }
}
