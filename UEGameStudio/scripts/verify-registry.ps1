[CmdletBinding()]
param(
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Assert-NoCondition {
    param(
        [bool]$Condition,
        [string]$Message
    )
    if (-not $Condition) {
        throw "REGISTRY MISMATCH: $Message"
    }
}

$packageRoot = Split-Path -Parent $PSScriptRoot
$agentsDir = Join-Path $packageRoot 'agents'
$registryPath = Join-Path $packageRoot 'docs\agent-registry.json'

Assert-NoCondition (Test-Path -LiteralPath $agentsDir -PathType Container) "agents directory does not exist: $agentsDir"
Assert-NoCondition (Test-Path -LiteralPath $registryPath -PathType Leaf) "registry not found: $registryPath"

$registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
Assert-NoCondition ($null -ne $registry -and $registry.agents -is [System.Array]) 'registry must contain an agents array.'

$actualFiles = @(Get-ChildItem -LiteralPath $agentsDir -Recurse -Filter '*.md' -File | Where-Object Name -ne '_ template.md')
$actualFiles = @($actualFiles | Where-Object { $_.Name -ne '_template.md' })

Assert-NoCondition ($registry.agentCount -eq $actualFiles.Count) "agentCount in registry ($($registry.agentCount)) does not match actual files ($($actualFiles.Count))."

$agentsById = @{}
foreach ($entry in $registry.agents) {
    Assert-NoCondition (-not $agentsById.ContainsKey([string]$entry.id)) "duplicate registry id: $($entry.id)"
    $agentsById[[string]$entry.id] = $entry
}

$registeredFiles = @{}
foreach ($entry in $registry.agents) {
    $file = Join-Path $agentsDir ($entry.file -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    Assert-NoCondition (Test-Path -LiteralPath $file -PathType Leaf) "registry entry $($entry.id) points to missing file: $($entry.file)"
    $registeredFiles[(Resolve-Path -LiteralPath $file).Path] = $entry.id
}

function Get-Frontmatter {
    param([string]$Path)
    $lines = @(Get-Content -LiteralPath $Path)
    $first = -1
    $second = -1
    for ($i = 0; $i -lt $lines.Count -and $second -lt 0; $i++) {
        if ($lines[$i].Trim() -eq '---') {
            if ($first -lt 0) { $first = $i } else { $second = $i }
        }
    }
    Assert-NoCondition ($first -ge 0 -and $second -gt $first) "missing YAML frontmatter in $Path"
    $fm = $lines[($first + 1)..($second - 1)]
    if ($null -eq $fm) { $fm = @() }
    return $fm
}

function Get-FmValue {
    param([string[]]$Frontmatter, [string]$Key)
    $match = $Frontmatter | Where-Object { $_ -match "^$Key\s*:" } | Select-Object -First 1
    if ($null -eq $match) { return $null }
    return ($match -replace "^$Key\s*:\s*", '').Trim()
}

function Get-PermissionSummary {
    param([string[]]$Frontmatter)
    $permIndex = -1
    for ($i = 0; $i -lt $Frontmatter.Count; $i++) {
        if ($Frontmatter[$i] -match '^permission\s*:') { $permIndex = $i; break }
    }
    if ($permIndex -lt 0) { throw 'frontmatter has no permission block.' }
    $block = @()
    for ($i = $permIndex + 1; $i -lt $Frontmatter.Count; $i++) {
        if ($Frontmatter[$i] -match '^\S') { break }
        $block += $Frontmatter[$i]
    }
    $summary = @{}
    foreach ($k in @('task', 'bash', 'webfetch', 'external_directory', 'edit')) {
        $line = $block | Where-Object { $_ -match "^[ \t]*${k}\s*:" } | Select-Object -First 1
        if ($null -eq $line) { $summary[$k] = 'deny'; continue }
        $value = ($line -replace "^[ \t]*${k}\s*:\s*", '').Trim()
        if ($value -eq 'allow' -or $value -eq 'deny') {
            $summary[$k] = $value
        }
        elseif ($value -eq '') {
            $allowed = @($block | Where-Object { $_ -match '^[ \t]{4,}.+:\s*allow\s*$' } | ForEach-Object {
                $spread = $_ -replace '^[ \t]+', ''
                $pathOnly = ($spread -split ':', 2)[0].Trim().Trim('"')
                $pathOnly
            })
            $summary[$k] = 'restricted:' + [string]::Join(';', $allowed)
        }
        else {
            $summary[$k] = $value
        }
    }
$wild = $block | Where-Object { $_ -match '^[ \t]*"\*"\s*:' } | Select-Object -First 1
    $summary['default'] = $null
    if ($null -ne $wild) {
        $summary['default'] = ($wild -replace '^[ \t]*"\*"\s*:\s*', '').Trim()
        if ($summary['default'] -match '^"(.+)"$') { $summary['default'] = $Matches[1] }
    }
    return $summary
}

function Get-BodyTitle {
    param([string]$Path)
    $t = Select-String -LiteralPath $Path -Pattern '^# ' | Select-Object -First 1
    if ($null -eq $t) { return '' }
    return ($t.Line -replace '^#\s*', '').Trim()
}

$issues = @()
foreach ($entry in $registry.agents) {
    $id = [string]$entry.id
    $file = Join-Path $agentsDir ($entry.file -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    $fm = Get-Frontmatter -Path $file

    $mode = Get-FmValue -Frontmatter $fm -Key 'mode'
    if ($mode -ne 'subagent') { $issues += "${id}: mode is '$mode', expected subagent" }

    if ($entry.title -ne (Get-BodyTitle -Path $file)) { $issues += "${id}: title mismatch" }

    $desc = Get-FmValue -Frontmatter $fm -Key 'description'
    if ($entry.description -ne $desc) { $issues += "${id}: description mismatch" }

    $summary = Get-PermissionSummary -Frontmatter $fm
    if ($summary['default'] -ne 'deny') { $issues += "${id}: default permission is '$($summary['default'])', expected deny" }
    foreach ($k in @('task', 'bash', 'webfetch', 'external_directory', 'edit')) {
        if ($entry.permission.$k -ne $summary[$k]) {
            $issues += "${id}: permission.$k is '$($summary[$k])', registry has '$($entry.permission.$k)'"
        }
    }
}

foreach ($file in $actualFiles) {
    $resolved = (Resolve-Path -LiteralPath $file.FullName).Path
    if (-not $registeredFiles.ContainsKey($resolved)) {
        $issues += "actual file $($file.Name) has no registry entry"
    }
}

if ($issues.Count -gt 0) {
    Write-Host "Registry drift found ($($issues.Count) issue(s)):"
    foreach ($issue in $issues) { Write-Host "  - $issue" }
    Write-Host "REGISTRY_VERIFY: FAIL"
    exit 1
}

Write-Host "REGISTRY_VERIFY: PASS ($($registry.agentCount) agents verified)"
exit 0