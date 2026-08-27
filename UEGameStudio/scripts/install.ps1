[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TargetProject,

    [switch]$AllowMissingUProject,

    [switch]$NoConfigBackup
)

$ErrorActionPreference = 'Stop'

function Get-NormalizedFullPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.Path]::GetFullPath($Path).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
}

function Ensure-Directory {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

$packageRoot = Get-NormalizedFullPath (Split-Path -Parent $PSScriptRoot)
$targetRoot = Get-NormalizedFullPath $TargetProject

if (-not (Test-Path -LiteralPath $targetRoot -PathType Container)) {
    throw "Target project directory does not exist: $targetRoot"
}

if (-not $AllowMissingUProject) {
    $uprojects = @(Get-ChildItem -LiteralPath $targetRoot -Filter '*.uproject' -File)
    if ($uprojects.Count -eq 0) {
        throw "No .uproject found directly under target project. Use -AllowMissingUProject only for an intentional non-UE test fixture."
    }
}

$sourceAgents = Join-Path $packageRoot 'agents'
$sourceInstructions = Join-Path $packageRoot 'AGENTS.md'
$sourceValidation = Join-Path $packageRoot 'docs\formal-project-validation.md'

foreach ($requiredSource in @($sourceAgents, $sourceInstructions, $sourceValidation)) {
    if (-not (Test-Path -LiteralPath $requiredSource)) {
        throw "Required package content is missing: $requiredSource"
    }
}

$targetAgentRoot = Join-Path $targetRoot '.opencode\agent'
Ensure-Directory $targetAgentRoot

$agentFiles = @(Get-ChildItem -LiteralPath $sourceAgents -Recurse -Filter '*.md' -File | Where-Object Name -ne '_template.md')
foreach ($agentFile in $agentFiles) {
    $relativePath = $agentFile.FullName.Substring($sourceAgents.Length).TrimStart(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $destination = Join-Path $targetAgentRoot $relativePath
    Ensure-Directory (Split-Path -Parent $destination)
    Copy-Item -LiteralPath $agentFile.FullName -Destination $destination -Force
}

$targetProductRoot = Join-Path $targetRoot 'UEGameStudio'
$targetProductDocs = Join-Path $targetProductRoot 'docs'
Ensure-Directory $targetProductRoot
Ensure-Directory $targetProductDocs
Copy-Item -LiteralPath $sourceInstructions -Destination (Join-Path $targetProductRoot 'AGENTS.md') -Force
Copy-Item -LiteralPath $sourceValidation -Destination (Join-Path $targetProductDocs 'formal-project-validation.md') -Force

$configPath = Join-Path $targetRoot 'opencode.json'
$schemaUrl = 'https://opencode.ai/config.json'
$requiredInstructions = @('UEGameStudio/AGENTS.md')

if (Test-Path -LiteralPath $configPath -PathType Leaf) {
    $rawConfig = Get-Content -LiteralPath $configPath -Raw
    try {
        $config = $rawConfig | ConvertFrom-Json
    }
    catch {
        throw "Existing opencode.json is not valid JSON. It was not modified: $($_.Exception.Message)"
    }

    if ($null -eq $config -or $config -is [System.Array]) {
        throw 'Existing opencode.json must contain a JSON object. It was not modified.'
    }

    if (-not $NoConfigBackup) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backupPath = "$configPath.uegamestudio-$timestamp.bak"
        Copy-Item -LiteralPath $configPath -Destination $backupPath
    }
}
else {
    $config = [pscustomobject][ordered]@{
        '$schema' = $schemaUrl
        instructions = @()
    }
}

$schemaProperty = $config.PSObject.Properties['$schema']
if ($null -eq $schemaProperty) {
    $config | Add-Member -NotePropertyName '$schema' -NotePropertyValue $schemaUrl
}
else {
    $config.'$schema' = $schemaUrl
}

$instructionList = [System.Collections.Generic.List[string]]::new()
$instructionsProperty = $config.PSObject.Properties['instructions']
if ($null -ne $instructionsProperty -and $null -ne $config.instructions) {
    foreach ($instruction in @($config.instructions)) {
        if ($instruction -isnot [string]) {
            throw 'Existing opencode.json instructions must contain only strings. It was not modified.'
        }
        if (-not $instructionList.Contains($instruction)) {
            $instructionList.Add($instruction)
        }
    }
}

foreach ($requiredInstruction in $requiredInstructions) {
    if (-not $instructionList.Contains($requiredInstruction)) {
        $instructionList.Add($requiredInstruction)
    }
}

if ($null -eq $instructionsProperty) {
    $config | Add-Member -NotePropertyName 'instructions' -NotePropertyValue ([string[]]$instructionList)
}
else {
    $config.instructions = [string[]]$instructionList
}

$json = $config | ConvertTo-Json -Depth 100
$temporaryConfig = "$configPath.uegamestudio-$([guid]::NewGuid().ToString('N')).tmp"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($temporaryConfig, $json + [Environment]::NewLine, $utf8NoBom)
Move-Item -LiteralPath $temporaryConfig -Destination $configPath -Force

Write-Host "Installed $($agentFiles.Count) UEGameStudio agents."
Write-Host "Installed project instructions: $(Join-Path $targetProductRoot 'AGENTS.md')"
Write-Host "Installed validation method: $(Join-Path $targetProductDocs 'formal-project-validation.md')"
Write-Host "Updated opencode configuration: $configPath"
