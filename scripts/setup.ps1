# scripts/setup.ps1
# PowerShell-native port of Claude Scholar Installer for Antigravity 2.0 native plugin structure

$ErrorActionPreference = "Stop"

$CLAUDE_DIR = "$env:USERPROFILE\.gemini\config\plugins\claude-scholar"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$SRC_DIR = Split-Path -Parent $SCRIPT_DIR
$COMPONENTS = @('skills', 'commands', 'agents', 'rules', 'hooks', 'scripts', 'templates')
$CLAUDE_MD_SIDECAR = "CLAUDE.scholar.md"
$CLAUDE_ZH_MD_SIDECAR = "CLAUDE.zh-CN.scholar.md"
$BACKUP_ROOT = Join-Path $CLAUDE_DIR ".claude-scholar-backups"
$MANIFEST_FILE = Join-Path $CLAUDE_DIR ".claude-scholar-manifest.txt"
$STATE_FILE = Join-Path $CLAUDE_DIR ".claude-scholar-install-state"
$BACKUP_STAMP = (Get-Date -Format "yyyyMMdd-HHmmss")
$BACKUP_DIR = Join-Path $BACKUP_ROOT $BACKUP_STAMP
$BACKUP_READY = $false
$BACKUP_COUNT = 0
$UPDATED_COUNT = 0
$SKIPPED_COUNT = 0
$SETTINGS_CREATED = 0
$MANAGED_PATHS = [System.Collections.Generic.List[string]]::new()
$CLAUDE_TARGETS = [System.Collections.Generic.List[string]]::new()
$SETTINGS_META_FILE = [System.IO.Path]::GetTempFileName()
$LEGACY_INSTALL_DETECTED = $false

$PREVIOUS_MANAGED_PATHS = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

# Helper functions
function Write-Info($msg) {
    Write-Host "[INFO] $msg" -ForegroundColor Cyan
}

function Write-Warn($msg) {
    Write-Host "[WARN] $msg" -ForegroundColor Yellow
}

function Write-Err($msg) {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
    exit 1
}

function Get-RelativePath($path, $base) {
    $absPath = [System.IO.Path]::GetFullPath($path).Replace('\', '/')
    $absBase = [System.IO.Path]::GetFullPath($base).Replace('\', '/')
    if (-not $absBase.EndsWith('/')) {
        $absBase += '/'
    }
    if ($absPath.StartsWith($absBase)) {
        return $absPath.Substring($absBase.Length)
    }
    return $null
}

function Check-Deps {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Err "Git is required. Install it first."
    }
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        Write-Err "Node.js is required (hooks depend on it). Install it first."
    }
}

function Load-PreviousManifest {
    if (Test-Path $MANIFEST_FILE) {
        $lines = Get-Content -Path $MANIFEST_FILE
        foreach ($line in $lines) {
            $trimmed = $line.Trim()
            if ($trimmed) {
                [void]$PREVIOUS_MANAGED_PATHS.Add($trimmed)
            }
        }
    }
}

function Detect-LegacyInstall {
    $settingsPath = Join-Path $CLAUDE_DIR "settings.json"
    if (Test-Path $MANIFEST_FILE) { return }
    if (!(Test-Path $settingsPath)) { return }
    
    try {
        $settingsContent = Get-Content -Raw -Path $settingsPath -ErrorAction SilentlyContinue
        if (-not $settingsContent) { return }
        $settings = ConvertFrom-Json $settingsContent
        
        $hookNeedles = @(
            '.claude/hooks/security-guard.js',
            '.claude/hooks/session-summary.js',
            '.claude/hooks/session-start.js',
            '.claude/hooks/stop-summary.js',
            '.claude/hooks/skill-forced-eval.js'
        )
        
        $detected = $false
        if ($settings.hooks) {
            foreach ($matchers in $settings.hooks.PSObject.Properties.Value) {
                if ($matchers -is [array]) {
                    foreach ($matcher in $matchers) {
                        if ($matcher.hooks -is [array]) {
                            foreach ($hook in $matcher.hooks) {
                                if ($hook.command -is [string]) {
                                    foreach ($needle in $hookNeedles) {
                                        if ($hook.command.Contains($needle)) {
                                            $detected = $true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if ($detected) {
            $global:LEGACY_INSTALL_DETECTED = $true
        }
    } catch {
        # ignore parsing error
    }
}

function Record-ManagedPath($targetPath) {
    $rel = Get-RelativePath $targetPath $CLAUDE_DIR
    if (-not $rel) { return }
    if (-not $MANAGED_PATHS.Contains($rel)) {
        [void]$MANAGED_PATHS.Add($rel)
    }
}

function Record-ClaudeTarget($targetPath) {
    $rel = Get-RelativePath $targetPath $CLAUDE_DIR
    if (-not $rel) { return }
    if (-not $CLAUDE_TARGETS.Contains($rel)) {
        [void]$CLAUDE_TARGETS.Add($rel)
    }
}

function Was-PreviouslyManaged($targetPath) {
    $rel = Get-RelativePath $targetPath $CLAUDE_DIR
    if (-not $rel) { return $false }
    return $PREVIOUS_MANAGED_PATHS.Contains($rel)
}

function Should-AdoptExistingPath($targetPath) {
    if (Was-PreviouslyManaged $targetPath) {
        return $true
    }
    return $global:LEGACY_INSTALL_DETECTED
}

function Ensure-BackupDir {
    if (-not $global:BACKUP_READY) {
        New-Item -ItemType Directory -Force -Path $BACKUP_DIR | Out-Null
        $global:BACKUP_READY = $true
        Write-Info "Backup directory: $BACKUP_DIR"
    }
}

function Backup-Path($targetPath) {
    if (-not (Test-Path $targetPath)) { return }
    Ensure-BackupDir
    
    $rel = Get-RelativePath $targetPath $CLAUDE_DIR
    if (-not $rel) {
        $rel = Split-Path -Leaf $targetPath
    }
    
    $dest = Join-Path $BACKUP_DIR $rel
    $destParent = Split-Path -Parent $dest
    if (-not (Test-Path $destParent)) {
        New-Item -ItemType Directory -Force -Path $destParent | Out-Null
    }
    
    if (Test-Path -Path $targetPath -PathType Container) {
        Copy-Item -Recurse -Force -Path $targetPath -Destination $dest | Out-Null
    } else {
        Copy-Item -Force -Path $targetPath -Destination $dest | Out-Null
    }
    $global:BACKUP_COUNT++
}

function Create-Settings {
    $target = "$env:USERPROFILE\.gemini\config\mcp_config.json"
    if (!(Test-Path $target)) {
        $parent = Split-Path -Parent $target
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Force -Path $parent | Out-Null
        }
        Set-Content -Path $target -Value '{"mcpServers": {}}' -Encoding utf8
        $global:SETTINGS_CREATED = 1
        Write-Info "Created empty mcp_config.json."
    }
}

function Merge-Settings($srcDir) {
    $template = Join-Path $srcDir "settings.json.template"
    $target = "$env:USERPROFILE\.gemini\config\mcp_config.json"
    
    if (!(Test-Path $template)) { return }
    if (!(Test-Path $target)) { Create-Settings }
    
    Backup-Path $target
    
    $bak = "$target.bak"
    Copy-Item -Force -Path $target -Destination $bak | Out-Null
    Write-Info "Backed up mcp_config.json -> mcp_config.json.bak"
    
    $env:CLAUDE_SETTINGS_TARGET = $target
    $env:CLAUDE_SETTINGS_TEMPLATE = $template
    $env:CLAUDE_SETTINGS_META_FILE = $SETTINGS_META_FILE
    
    $nodeScript = @"
const fs = require('fs');
const targetPath = process.env.CLAUDE_SETTINGS_TARGET;
const templatePath = process.env.CLAUDE_SETTINGS_TEMPLATE;
const metaPath = process.env.CLAUDE_SETTINGS_META_FILE;
const existing = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
const template = JSON.parse(fs.readFileSync(templatePath, 'utf8'));
const addedMcpServers = [];
const addedMcpServerFields = {};

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function mergeMissing(existingValue, templateValue, pathParts, addedPaths) {
  if (existingValue === undefined) return clone(templateValue);
  if (templateValue === null || Array.isArray(templateValue) || typeof templateValue !== 'object') {
    return existingValue;
  }

  const output = { ...existingValue };
  for (const [key, value] of Object.entries(templateValue)) {
    if (!(key in output)) {
      output[key] = clone(value);
      addedPaths.push([...pathParts, key].join('.'));
      continue;
    }
    if (
      output[key] &&
      value &&
      !Array.isArray(output[key]) &&
      !Array.isArray(value) &&
      typeof output[key] === 'object' &&
      typeof value === 'object'
    ) {
      output[key] = mergeMissing(output[key], value, [...pathParts, key], addedPaths);
    }
  }
  return output;
}

existing.mcpServers = existing.mcpServers || {};

if (template.mcpServers) {
  for (const [key, value] of Object.entries(template.mcpServers)) {
    if (!(key in existing.mcpServers)) {
      addedMcpServers.push(key);
      existing.mcpServers[key] = clone(value);
      continue;
    }
    const addedPaths = [];
    existing.mcpServers[key] = mergeMissing(existing.mcpServers[key], value, [], addedPaths);
    if (addedPaths.length > 0) {
      addedMcpServerFields[key] = addedPaths;
    }
  }
}

fs.writeFileSync(targetPath, JSON.stringify(existing, null, 2) + '\n');
fs.writeFileSync(metaPath, JSON.stringify({
  addedHooks: [],
  addedMcpServers,
  addedMcpServerFields,
  addedEnabledPlugins: [],
}, null, 2) + '\n');
"@

    $tempJs = [System.IO.Path]::GetTempFileName() + ".js"
    Set-Content -Path $tempJs -Value $nodeScript -Encoding utf8
    
    $process = Start-Process node -ArgumentList $tempJs -NoNewWindow -PassThru -Wait
    Remove-Item -Path $tempJs -Force -ErrorAction SilentlyContinue
    
    if ($process.ExitCode -ne 0) {
        Write-Warning "Auto-merge failed. Please manually copy mcpServers from settings.json.template."
    } else {
        Write-Info "Merged mcpServers into mcp_config.json without touching existing configurations."
    }
}

function Copy-FileSafely($srcFile, $targetFile) {
    $parent = Split-Path -Parent $targetFile
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    
    if (Test-Path $targetFile) {
        $srcHash = Get-FileHash -Path $srcFile -Algorithm SHA256
        $targetHash = Get-FileHash -Path $targetFile -Algorithm SHA256
        if ($srcHash.Hash -eq $targetHash.Hash) {
            if (Should-AdoptExistingPath $targetFile) {
                Record-ManagedPath $targetFile
            }
            $global:SKIPPED_COUNT++
            return
        }
    }
    
    if (Test-Path $targetFile) {
        Backup-Path $targetFile
        if (Test-Path -Path $targetFile -PathType Container) {
            Remove-Item -Recurse -Force -Path $targetFile | Out-Null
        }
    }
    
    Copy-Item -Force -Path $srcFile -Destination $targetFile | Out-Null
    Record-ManagedPath $targetFile
    $global:UPDATED_COUNT++
}

function Copy-DirSafely($srcDir, $targetDir) {
    if (Test-Path $targetDir) {
        if (-not (Test-Path -Path $targetDir -PathType Container)) {
            Backup-Path $targetDir
            Remove-Item -Force -Path $targetDir | Out-Null
        }
    }
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    
    $files = Get-ChildItem -Path $srcDir -Recurse -File
    foreach ($file in $files) {
        $rel = Get-RelativePath $file.FullName $srcDir
        $targetFile = Join-Path $targetDir $rel
        Copy-FileSafely $file.FullName $targetFile
    }
}

function Install-ClaudeMd($srcFile) {
    $targetFile = Join-Path $CLAUDE_DIR "CLAUDE.md"
    $sidecarFile = Join-Path $CLAUDE_DIR $CLAUDE_MD_SIDECAR
    
    if ((Test-Path $targetFile) -and (Should-AdoptExistingPath $targetFile)) {
        Copy-FileSafely $srcFile $targetFile
        Record-ClaudeTarget $targetFile
        return
    }
    
    if (Test-Path $targetFile) {
        Write-Warn "Preserving existing CLAUDE.md"
        Copy-FileSafely $srcFile $sidecarFile
        Record-ClaudeTarget $sidecarFile
        Write-Info "Installed repository CLAUDE.md as $CLAUDE_MD_SIDECAR"
        return
    }
    
    Copy-FileSafely $srcFile $targetFile
    Record-ClaudeTarget $targetFile
}

function Install-ClaudeZhMd($srcFile) {
    $targetFile = Join-Path $CLAUDE_DIR "CLAUDE.zh-CN.md"
    $sidecarFile = Join-Path $CLAUDE_DIR $CLAUDE_ZH_MD_SIDECAR
    
    if ((Test-Path $targetFile) -and (Should-AdoptExistingPath $targetFile)) {
        Copy-FileSafely $srcFile $targetFile
        Record-ClaudeTarget $targetFile
        return
    }
    
    if (Test-Path $targetFile) {
        Write-Warn "Preserving existing CLAUDE.zh-CN.md"
        Copy-FileSafely $srcFile $sidecarFile
        Record-ClaudeTarget $sidecarFile
        Write-Info "Installed repository CLAUDE.zh-CN.md as $CLAUDE_ZH_MD_SIDECAR"
        return
    }
    
    Copy-FileSafely $srcFile $targetFile
    Record-ClaudeTarget $targetFile
}

function Copy-Components($src) {
    $pluginJson = Join-Path $src ".claude-plugin\plugin.json"
    if (Test-Path $pluginJson) {
        Copy-FileSafely $pluginJson (Join-Path $CLAUDE_DIR "plugin.json")
        Copy-FileSafely $pluginJson (Join-Path $CLAUDE_DIR "plugins.json")
    }
    
    $claudeMd = Join-Path $src "CLAUDE.md"
    if (Test-Path $claudeMd) {
        Install-ClaudeMd $claudeMd
    }
    
    $claudeZhMd = Join-Path $src "CLAUDE.zh-CN.md"
    if (Test-Path $claudeZhMd) {
        Install-ClaudeZhMd $claudeZhMd
    }
    
    foreach ($comp in $COMPONENTS) {
        $compPath = Join-Path $src $comp
        if (Test-Path $compPath) {
            $destPath = Join-Path $CLAUDE_DIR $comp
            if (Test-Path -Path $compPath -PathType Container) {
                Copy-DirSafely $compPath $destPath
            } else {
                Copy-FileSafely $compPath $destPath
            }
        }
    }
    
    Write-Info "Updated components: $($COMPONENTS -join ' ')"
}

function Write-InstallState {
    if (-not (Test-Path $CLAUDE_DIR)) {
        New-Item -ItemType Directory -Force -Path $CLAUDE_DIR | Out-Null
    }
    
    $uniqueManaged = $MANAGED_PATHS | Sort-Object -Unique
    if ($uniqueManaged) {
        Set-Content -Path $MANIFEST_FILE -Value $uniqueManaged -Encoding utf8
    } else {
        Clear-Content -Path $MANIFEST_FILE -ErrorAction SilentlyContinue
    }
    
    $managedPathsTemp = [System.IO.Path]::GetTempFileName()
    $claudeTargetsTemp = [System.IO.Path]::GetTempFileName()
    
    if ($MANAGED_PATHS) {
        $MANAGED_PATHS | Sort-Object -Unique | Set-Content -Path $managedPathsTemp -Encoding utf8
    }
    if ($CLAUDE_TARGETS) {
        $CLAUDE_TARGETS | Sort-Object -Unique | Set-Content -Path $claudeTargetsTemp -Encoding utf8
    }
    
    $env:CLAUDE_STATE_FILE = $STATE_FILE
    $env:CLAUDE_SETTINGS_META_FILE = $SETTINGS_META_FILE
    $env:CLAUDE_MANAGED_PATHS_FILE = $managedPathsTemp
    $env:CLAUDE_TARGETS_FILE = $claudeTargetsTemp
    $env:CLAUDE_INSTALLED_AT = $BACKUP_STAMP
    $env:CLAUDE_SOURCE_DIR = $SRC_DIR
    $env:CLAUDE_SETTINGS_CREATED = $SETTINGS_CREATED.ToString()
    $env:CLAUDE_BACKUP_DIR = $BACKUP_DIR
    $env:CLAUDE_BACKUP_READY = if ($BACKUP_READY) { "1" } else { "0" }
    
    $nodeScript = @"
const fs = require('fs');

function readLines(path) {
  if (!path || !fs.existsSync(path)) return [];
  return fs.readFileSync(path, 'utf8').split('\n').map((line) => line.trim()).filter(Boolean);
}

function readJson(path) {
  if (!path || !fs.existsSync(path)) return {};
  return JSON.parse(fs.readFileSync(path, 'utf8'));
}

const state = {
  installedAt: process.env.CLAUDE_INSTALLED_AT,
  sourceDir: process.env.CLAUDE_SOURCE_DIR,
  settingsCreated: process.env.CLAUDE_SETTINGS_CREATED === '1',
  backupDir: process.env.CLAUDE_BACKUP_READY === '1' ? process.env.CLAUDE_BACKUP_DIR : '',
  managedPaths: readLines(process.env.CLAUDE_MANAGED_PATHS_FILE),
  claudeTargets: readLines(process.env.CLAUDE_TARGETS_FILE),
  settings: readJson(process.env.CLAUDE_SETTINGS_META_FILE),
};

fs.writeFileSync(process.env.CLAUDE_STATE_FILE, JSON.stringify(state, null, 2) + '\n');
"@

    $tempJs = [System.IO.Path]::GetTempFileName() + ".js"
    Set-Content -Path $tempJs -Value $nodeScript -Encoding utf8
    node $tempJs
    Remove-Item -Path $tempJs -Force -ErrorAction SilentlyContinue
    
    Remove-Item -Path $managedPathsTemp -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $claudeTargetsTemp -Force -ErrorAction SilentlyContinue
}

function Main {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║       Claude Scholar Installer       ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Check-Deps
    Load-PreviousManifest
    Detect-LegacyInstall
    
    Write-Info "Installing from: $SRC_DIR"
    Copy-Components $SRC_DIR
    Merge-Settings $SRC_DIR
    Write-InstallState
    
    Write-Info "Your existing env/model/API key/permissions settings are preserved."
    Write-Info "Install manifest: $MANIFEST_FILE"
    Write-Info "Updated files: $global:UPDATED_COUNT | Unchanged files skipped: $global:SKIPPED_COUNT | Backups created: $global:BACKUP_COUNT"
    
    if ($global:BACKUP_READY) {
        Write-Info "Recover previous files from: $BACKUP_DIR"
    }
    
    Write-Host ""
    Write-Info "Done! Restart Claude Code CLI to activate."
    Write-Host ""
}

try {
    Main
} finally {
    if (Test-Path $SETTINGS_META_FILE) {
        Remove-Item -Path $SETTINGS_META_FILE -Force -ErrorAction SilentlyContinue
    }
}
