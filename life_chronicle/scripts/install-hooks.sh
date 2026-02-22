#!/usr/bin/env bash
# Install Git Hooks Script
# Run this to set up pre-commit hooks for the project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
GIT_DIR="$REPO_DIR/.git"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}=========================================="
echo "  Git Hooks Installer"
echo "==========================================${NC}"
echo ""

if [ ! -d "$GIT_DIR" ]; then
    echo -e "${RED}❌ Not a git repository: $REPO_DIR${NC}"
    exit 1
fi

HOOKS_DIR="$GIT_DIR/hooks"
mkdir -p "$HOOKS_DIR"

echo -e "${BLUE}Installing pre-commit hook...${NC}"

if [ -f "$HOOKS_DIR/pre-commit" ]; then
    echo -e "${YELLOW}⚠️  Existing pre-commit hook found${NC}"
    BACKUP="$HOOKS_DIR/pre-commit.backup.$(date +%Y%m%d%H%M%S)"
    cp "$HOOKS_DIR/pre-commit" "$BACKUP"
    echo -e "${YELLOW}   Backed up to: $BACKUP${NC}"
fi

cat > "$HOOKS_DIR/pre-commit" << 'HOOK_EOF'
#!/usr/bin/env bash
# Git Pre-commit Hook for Flutter Android Project
# This hook runs before each commit to catch issues early

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
    echo -e "${YELLOW}⚠️  Pre-check script not found at scripts/pre-check.sh${NC}"
fi

echo ""
echo -e "${BLUE}Checking for large files (>5MB)...${NC}"
LARGE_FILES=$(git diff --cached --name-only 2>/dev/null | while read f; do
    if [ -f "$f" ]; then
        size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null || echo 0)
        if [ "$size" -gt 5242880 ]; then
            echo "$f"
        fi
    fi
done)
if [ -n "$LARGE_FILES" ]; then
    echo -e "${YELLOW}⚠️  Large files detected (>5MB):${NC}"
    echo "$LARGE_FILES"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "  ✅ Pre-commit checks passed!"
echo "==========================================${NC}"
echo ""

exit 0
HOOK_EOF

chmod +x "$HOOKS_DIR/pre-commit"

echo -e "${GREEN}✅ Pre-commit hook installed: $HOOKS_DIR/pre-commit${NC}"
echo ""

echo -e "${BLUE}=========================================="
echo "  Installation Complete!"
echo "==========================================${NC}"
echo ""
echo "The pre-commit hook will now run automatically before each commit."
echo ""
echo "To skip the hook temporarily, use:"
echo -e "  ${YELLOW}git commit --no-verify${NC}"
echo ""
echo "To run the pre-check script manually:"
echo -e "  ${YELLOW}./scripts/pre-check.sh${NC}"
echo ""
