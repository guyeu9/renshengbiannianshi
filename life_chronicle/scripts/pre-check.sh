#!/usr/bin/env bash
# Android Build Pre-check Script
# Run this before committing to catch configuration issues early

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo ""
echo "=========================================="
echo "  Android Build Pre-check"
echo "=========================================="
echo ""

check_pass() {
    echo -e "${GREEN}✅ $1${NC}"
}

check_fail() {
    echo -e "${RED}❌ $1${NC}"
    ERRORS=$((ERRORS + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    WARNINGS=$((WARNINGS + 1))
}

# Check 1: Namespace in all local plugins
echo "--- Check 1: Namespace Configuration ---"
for gradle in "$PROJECT_DIR"/plugins/*/android/build.gradle*; do
    if [ -f "$gradle" ]; then
        plugin_name=$(dirname "$gradle" | xargs dirname | xargs basename)
        if grep -q "namespace" "$gradle" 2>/dev/null; then
            ns=$(grep "namespace" "$gradle" | head -1 | sed 's/.*namespace[ =]*['\''"]*\([^'\''"]*\).*/\1/')
            check_pass "$plugin_name: namespace='$ns'"
        else
            check_fail "$plugin_name: MISSING namespace"
        fi
    fi
done
echo ""

# Check 2: AndroidManifest.xml package attribute
echo "--- Check 2: AndroidManifest.xml ---"
for manifest in "$PROJECT_DIR"/plugins/*/android/src/main/AndroidManifest.xml; do
    if [ -f "$manifest" ]; then
        plugin_name=$(echo "$manifest" | sed "s|$PROJECT_DIR/plugins/||" | cut -d'/' -f1)
        if grep -q 'package=' "$manifest" 2>/dev/null; then
            check_warn "$plugin_name: has deprecated package attribute in AndroidManifest.xml"
        else
            check_pass "$plugin_name: AndroidManifest.xml OK"
        fi
    fi
done
echo ""

# Check 3: SDK Version Consistency
echo "--- Check 3: SDK Version Consistency ---"
COMPILE_SDKS=$(grep -rh "compileSdk" "$PROJECT_DIR"/android "$PROJECT_DIR"/plugins --include="*.gradle*" 2>/dev/null | grep -oE '[0-9]+' | sort -u)
COMPILE_COUNT=$(echo "$COMPILE_SDKS" | wc -l | tr -d ' ')
if [ "$COMPILE_COUNT" -gt 1 ]; then
    check_warn "Multiple compileSdk versions found: $COMPILE_SDKS"
else
    check_pass "compileSdk consistent: $(echo $COMPILE_SDKS)"
fi

MIN_SDKS=$(grep -rh "minSdk" "$PROJECT_DIR"/android "$PROJECT_DIR"/plugins --include="*.gradle*" 2>/dev/null | grep -oE '[0-9]+' | sort -u)
MIN_COUNT=$(echo "$MIN_SDKS" | wc -l | tr -d ' ')
if [ "$MIN_COUNT" -gt 1 ]; then
    check_warn "Multiple minSdk versions found: $MIN_SDKS"
else
    check_pass "minSdk consistent: $(echo $MIN_SDKS)"
fi
echo ""

# Check 4: AMap SDK Version
echo "--- Check 4: AMap SDK Configuration ---"
AMAP_VERSIONS=$(grep -rh "com.amap.api:3dmap" "$PROJECT_DIR"/android "$PROJECT_DIR"/plugins --include="*.gradle*" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -u)
AMAP_COUNT=$(echo "$AMAP_VERSIONS" | wc -l | tr -d ' ')
if [ "$AMAP_COUNT" -gt 1 ]; then
    check_warn "Multiple AMap SDK versions: $AMAP_VERSIONS"
else
    check_pass "AMap SDK version: $(echo $AMAP_VERSIONS)"
fi

# Check for location SDK conflict
if grep -rq "com.amap.api:location" "$PROJECT_DIR"/android --include="*.gradle*" 2>/dev/null; then
    check_fail "location SDK conflicts with 3dmap (3dmap includes location classes)"
else
    check_pass "No duplicate location SDK"
fi
echo ""

# Check 5: Deprecated Configurations
echo "--- Check 5: Deprecated Configurations ---"
if grep -rq "lintOptions" "$PROJECT_DIR"/android "$PROJECT_DIR"/plugins --include="*.gradle*" 2>/dev/null; then
    check_warn "lintOptions found (use 'lint {}' instead)"
else
    check_pass "No deprecated lintOptions"
fi

if grep -rq "jcenter()" "$PROJECT_DIR"/android "$PROJECT_DIR"/plugins --include="*.gradle*" 2>/dev/null; then
    check_warn "jcenter() found (deprecated, use mavenCentral())"
else
    check_pass "No deprecated jcenter"
fi

if grep -rq "android.enableJetifier=true" "$PROJECT_DIR" --include="*.properties" 2>/dev/null; then
    check_warn "enableJetifier=true found (deprecated)"
else
    check_pass "No deprecated enableJetifier"
fi
echo ""

# Check 6: pubspec.yaml SDK compatibility
echo "--- Check 6: Dart SDK Compatibility ---"
MAIN_SDK=$(grep "sdk:" "$PROJECT_DIR"/pubspec.yaml | head -1 | sed 's/.*sdk: *//')
echo "Main project SDK: $MAIN_SDK"

for pubspec in "$PROJECT_DIR"/plugins/*/pubspec.yaml; do
    if [ -f "$pubspec" ]; then
        plugin_name=$(dirname "$pubspec" | xargs basename)
        plugin_sdk=$(grep "sdk:" "$pubspec" | head -1 | sed 's/.*sdk: *//' 2>/dev/null || echo "not specified")
        if [[ "$plugin_sdk" == *"<3.0.0"* ]] && [[ "$MAIN_SDK" == *">=3."* ]]; then
            check_fail "$plugin_name: SDK '$plugin_sdk' incompatible with main project"
        else
            check_pass "$plugin_name: SDK compatible"
        fi
    fi
done
echo ""

# Check 7: Local plugin overrides
echo "--- Check 7: Local Plugin Overrides ---"
if [ -f "$PROJECT_DIR"/.dart_tool/package_config.json ]; then
    for plugin in amap_flutter_base amap_flutter_map amap_flutter_location; do
        if grep -q "plugins/$plugin" "$PROJECT_DIR"/.dart_tool/package_config.json 2>/dev/null; then
            check_pass "$plugin -> local override"
        else
            check_fail "$plugin NOT using local override"
        fi
    done
else
    check_warn "package_config.json not found (run flutter pub get)"
fi
echo ""

# Summary
echo "=========================================="
echo "  Summary"
echo "=========================================="
echo ""
echo -e "Errors:   ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Pre-check FAILED with $ERRORS error(s)${NC}"
    echo "   Please fix the errors before committing."
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Pre-check passed with $WARNINGS warning(s)${NC}"
    echo "   Consider addressing the warnings."
    exit 0
else
    echo -e "${GREEN}✅ All checks passed!${NC}"
    exit 0
fi
