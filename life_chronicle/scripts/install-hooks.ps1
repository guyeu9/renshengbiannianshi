# Git Hooks Installer (PowerShell)
# Run this to set up pre-commit hooks for the project

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = "." }
$RepoDir = $ScriptDir
$GitDir = Join-Path $RepoDir ".git"

Write-Host ""
Write-Host "=========================================="
Write-Host "  Git Hooks Installer"
Write-Host "=========================================="
Write-Host ""

if (-not (Test-Path $GitDir)) {
    Write-Host "❌ Not a git repository: $RepoDir" -ForegroundColor Red
    exit 1
}

$HooksDir = Join-Path $GitDir "hooks"
New-Item -ItemType Directory -Force -Path $HooksDir | Out-Null

Write-Host "Installing pre-commit hook..." -ForegroundColor Cyan

$PreCommitPath = Join-Path $HooksDir "pre-commit"

if (Test-Path $PreCommitPath) {
    Write-Host "⚠️  Existing pre-commit hook found" -ForegroundColor Yellow
    $Backup = "$PreCommitPath.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $PreCommitPath $Backup
    Write-Host "   Backed up to: $Backup" -ForegroundColor Yellow
}

$PreCommitContent = @'
#!/usr/bin/env bash
# Git Pre-commit Hook for Flutter Android Project

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}=========================================="
echo "  Pre-commit Hook"
echo "==========================================${NC}"
echo ""

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$HOOK_DIR/../.." && pwd)"

if [ ! -f "$REPO_DIR/pubspec.yaml" ]; then
    echo -e "${YELLOW}⚠️  Not a Flutter project root, skipping Flutter checks${NC}"
    exit 0
fi

PRE_CHECK_SCRIPT="$REPO_DIR/scripts/pre-check.sh"
if [ -f "$PRE_CHECK_SCRIPT" ]; then
    echo -e "${BLUE}Running pre-check script...${NC}"
    chmod +x "$PRE_CHECK_SCRIPT"
    if ! "$PRE_CHECK_SCRIPT"; then
        echo ""
        echo -e "${RED}❌ Pre-check failed. Please fix the issues before committing.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Pre-check script not found${NC}"
fi

echo ""
echo -e "${GREEN}✅ Pre-commit checks passed!${NC}"
exit 0
'@

Set-Content -Path $PreCommitPath -Value $PreCommitContent -Encoding UTF8

Write-Host "✅ Pre-commit hook installed: $PreCommitPath" -ForegroundColor Green

# Also create a PowerShell version for Windows
$PreCommitPs1Path = Join-Path $HooksDir "pre-commit.ps1"

$PreCommitPs1Content = @'
# Pre-commit Hook (PowerShell)
$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Write-Host ""
Write-Host "=========================================="
Write-Host "  Pre-commit Hook"
Write-Host "=========================================="
Write-Host ""

$PreCheckScript = Join-Path $RepoDir "scripts\pre-check.ps1"
if (Test-Path $PreCheckScript) {
    Write-Host "Running pre-check script..." -ForegroundColor Cyan
    & $PreCheckScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "❌ Pre-check failed. Please fix the issues before committing." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⚠️  Pre-check script not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Pre-commit checks passed!" -ForegroundColor Green
exit 0
'@

Set-Content -Path $PreCommitPs1Path -Value $PreCommitPs1Content -Encoding UTF8

Write-Host "✅ PowerShell hook installed: $PreCommitPs1Path" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================="
Write-Host "  Installation Complete!"
Write-Host "=========================================="
Write-Host ""
Write-Host "The pre-commit hook will now run automatically before each commit."
Write-Host ""
Write-Host "To skip the hook temporarily, use:"
Write-Host "  git commit --no-verify" -ForegroundColor Yellow
Write-Host ""
Write-Host "To run the pre-check script manually:"
Write-Host "  .\scripts\pre-check.ps1" -ForegroundColor Yellow
Write-Host ""
