# Android Build Pre-check Script (PowerShell)
# Run this before committing to catch configuration issues early

param(
    [switch]$Verbose,
    [switch]$SkipAnalyze
)

$ErrorActionPreference = "Continue"
$ProjectDir = Split-Path -Parent $PSScriptRoot
if (-not $ProjectDir) { $ProjectDir = "." }

$Errors = 0
$Warnings = 0

function Write-Pass { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Fail { param($msg) Write-Host "❌ $msg" -ForegroundColor Red; $script:Errors++ }
function Write-Warn { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow; $script:Warnings++ }
function Write-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Cyan }

Write-Host ""
Write-Host "=========================================="
Write-Host "  Android Build Pre-check"
Write-Host "=========================================="
Write-Host ""

# Check 1: Namespace in all local plugins
Write-Host "--- Check 1: Namespace Configuration ---"
$pluginGradles = Get-ChildItem -Path "$ProjectDir\plugins\*\android\build.gradle*" -ErrorAction SilentlyContinue
foreach ($gradle in $pluginGradles) {
    $pluginName = $gradle.Directory.Parent.Name
    $content = Get-Content $gradle.FullName -Raw
    if ($content -match "namespace\s*[=:]\s*['`"]([^'`"]+)['`"]") {
        Write-Pass "$pluginName`: namespace='$($Matches[1])'"
    } else {
        Write-Fail "$pluginName`: MISSING namespace in $($gradle.Name)"
    }
}
Write-Host ""

# Check 2: AndroidManifest.xml package attribute
Write-Host "--- Check 2: AndroidManifest.xml ---"
$manifestFiles = Get-ChildItem -Path "$ProjectDir\plugins\*\android\src\main\AndroidManifest.xml" -ErrorAction SilentlyContinue
foreach ($manifest in $manifestFiles) {
    $pluginName = $manifest.Directory.Parent.Parent.Parent.Name
    $content = Get-Content $manifest.FullName -Raw
    if ($content -match 'package=') {
        Write-Warn "$pluginName`: has deprecated package attribute in AndroidManifest.xml"
    } else {
        Write-Pass "$pluginName`: AndroidManifest.xml OK"
    }
}
Write-Host ""

# Check 3: SDK Version Consistency
Write-Host "--- Check 3: SDK Version Consistency ---"
$allGradles = Get-ChildItem -Path "$ProjectDir\android\*\*.gradle*", "$ProjectDir\plugins\*\android\*.gradle*" -ErrorAction SilentlyContinue

$compileSdkValues = @()
$minSdkValues = @()
foreach ($gradle in $allGradles) {
    $content = Get-Content $gradle.FullName -Raw
    if ($content -match "compileSdk\s*[=:]?\s*(\d+)") {
        $compileSdkValues += $Matches[1]
    }
    if ($content -match "minSdk\s*[=:]?\s*(\d+)") {
        $minSdkValues += $Matches[1]
    }
}

$uniqueCompileSdk = $compileSdkValues | Select-Object -Unique
$uniqueMinSdk = $minSdkValues | Select-Object -Unique

if ($uniqueCompileSdk.Count -gt 1) {
    Write-Warn "Multiple compileSdk versions: $($uniqueCompileSdk -join ', ')"
} elseif ($uniqueCompileSdk.Count -eq 1) {
    Write-Pass "compileSdk consistent: $($uniqueCompileSdk[0])"
}

if ($uniqueMinSdk.Count -gt 1) {
    Write-Warn "Multiple minSdk versions: $($uniqueMinSdk -join ', ')"
} elseif ($uniqueMinSdk.Count -eq 1) {
    Write-Pass "minSdk consistent: $($uniqueMinSdk[0])"
}
Write-Host ""

# Check 4: AMap SDK Configuration
Write-Host "--- Check 4: AMap SDK Configuration ---"
$amapVersions = @()
foreach ($gradle in $allGradles) {
    $content = Get-Content $gradle.FullName -Raw
    if ($content -match "com\.amap\.api:3dmap:([0-9.]+)") {
        $amapVersions += $Matches[1]
    }
}

$uniqueAmapVersions = $amapVersions | Select-Object -Unique
if ($uniqueAmapVersions.Count -gt 1) {
    Write-Warn "Multiple AMap SDK versions: $($uniqueAmapVersions -join ', ')"
} elseif ($uniqueAmapVersions.Count -eq 1) {
    Write-Pass "AMap SDK version: $($uniqueAmapVersions[0])"
}

# Check for location SDK conflict
$hasLocationSdk = $false
foreach ($gradle in $allGradles) {
    $content = Get-Content $gradle.FullName -Raw
    if ($content -match "com\.amap\.api:location" -and $content -notmatch "compileOnly") {
        $hasLocationSdk = $true
        break
    }
}
if ($hasLocationSdk) {
    Write-Fail "location SDK conflicts with 3dmap (3dmap includes location classes)"
} else {
    Write-Pass "No duplicate location SDK"
}
Write-Host ""

# Check 5: Deprecated Configurations
Write-Host "--- Check 5: Deprecated Configurations ---"
$hasLintOptions = $false
$hasJcenter = $false
$hasJetifier = $false

foreach ($gradle in $allGradles) {
    $content = Get-Content $gradle.FullName -Raw
    if ($content -match "lintOptions\s*\{") {
        $hasLintOptions = $true
    }
    if ($content -match "jcenter\(\)") {
        $hasJcenter = $true
    }
}

$propFiles = Get-ChildItem -Path "$ProjectDir\*\gradle.properties" -ErrorAction SilentlyContinue
foreach ($prop in $propFiles) {
    $content = Get-Content $prop.FullName -Raw
    if ($content -match "android\.enableJetifier\s*=\s*true") {
        $hasJetifier = $true
    }
}

if ($hasLintOptions) { Write-Warn "lintOptions found (use 'lint {}' instead)" } else { Write-Pass "No deprecated lintOptions" }
if ($hasJcenter) { Write-Warn "jcenter() found (deprecated)" } else { Write-Pass "No deprecated jcenter" }
if ($hasJetifier) { Write-Warn "enableJetifier=true found (deprecated)" } else { Write-Pass "No deprecated enableJetifier" }
Write-Host ""

# Check 6: Dart SDK Compatibility
Write-Host "--- Check 6: Dart SDK Compatibility ---"
$mainPubspec = Get-Content "$ProjectDir\pubspec.yaml" -Raw
if ($mainPubspec -match "sdk:\s*[""']?(>=?[0-9.]+\s*<?[0-9.]+)[""']?") {
    $mainSdk = $Matches[1]
    Write-Info "Main project SDK: $mainSdk"
}

$pluginPubspecs = Get-ChildItem -Path "$ProjectDir\plugins\*\pubspec.yaml" -ErrorAction SilentlyContinue
foreach ($pubspec in $pluginPubspecs) {
    $pluginName = $pubspec.Directory.Name
    $content = Get-Content $pubspec.FullName -Raw
    if ($content -match "sdk:\s*[""']?(>=?[0-9.]+\s*<?[0-9.]+)[""']?") {
        $pluginSdk = $Matches[1]
        if ($pluginSdk -match "<3\.0\.0" -and $mainSdk -match ">=3\.") {
            Write-Fail "$pluginName`: SDK '$pluginSdk' incompatible with main project"
        } else {
            Write-Pass "$pluginName`: SDK compatible"
        }
    }
}
Write-Host ""

# Check 7: Local Plugin Overrides
Write-Host "--- Check 7: Local Plugin Overrides ---"
$packageConfig = "$ProjectDir\.dart_tool\package_config.json"
if (Test-Path $packageConfig) {
    $content = Get-Content $packageConfig -Raw
    foreach ($plugin in @("amap_flutter_base", "amap_flutter_map", "amap_flutter_location")) {
        if ($content -match "plugins/$plugin") {
            Write-Pass "$plugin -> local override"
        } else {
            Write-Fail "$plugin NOT using local override"
        }
    }
} else {
    Write-Warn "package_config.json not found (run flutter pub get)"
}
Write-Host ""

# Check 8: Flutter Analyze
Write-Host "--- Check 8: Flutter Analyze ---"
if ($SkipAnalyze) {
    Write-Info "Skipping flutter analyze (use without -SkipAnalyze to run)"
} else {
    $flutterCmd = $null
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        $flutterCmd = "flutter"
    } elseif ($env:FLUTTER_ROOT) {
        $flutterExe = Join-Path $env:FLUTTER_ROOT "bin\flutter.bat"
        if (Test-Path $flutterExe) {
            $flutterCmd = $flutterExe
        }
    }
    
    if ($flutterCmd) {
        Write-Info "Running flutter analyze..."
        Push-Location $ProjectDir
        
        # Run flutter pub get first if needed
        if (-not (Test-Path ".dart_tool\package_config.json")) {
            Write-Info "Running flutter pub get..."
            & $flutterCmd pub get 2>&1 | Select-Object -Last 5
        }
        
        # Run flutter analyze
        $analyzeOutput = & $flutterCmd analyze 2>&1
        $analyzeExitCode = $LASTEXITCODE
        
        Pop-Location
        
        if ($analyzeExitCode -eq 0) {
            Write-Pass "Flutter analyze passed"
        } else {
            Write-Host $analyzeOutput
            Write-Fail "Flutter analyze found issues (see above)"
        }
    } else {
        Write-Warn "Flutter not found in PATH - skipping flutter analyze"
        Write-Info "Install Flutter or set FLUTTER_ROOT environment variable"
    }
}
Write-Host ""

# Summary
Write-Host "=========================================="
Write-Host "  Summary"
Write-Host "=========================================="
Write-Host ""

Write-Host "Errors:   $Errors" -ForegroundColor $(if ($Errors -gt 0) { "Red" } else { "Green" })
Write-Host "Warnings: $Warnings" -ForegroundColor $(if ($Warnings -gt 0) { "Yellow" } else { "Green" })
Write-Host ""

if ($Errors -gt 0) {
    Write-Host "❌ Pre-check FAILED with $Errors error(s)" -ForegroundColor Red
    Write-Host "   Please fix the errors before committing."
    exit 1
} elseif ($Warnings -gt 0) {
    Write-Host "⚠️  Pre-check passed with $Warnings warning(s)" -ForegroundColor Yellow
    Write-Host "   Consider addressing the warnings."
    exit 0
} else {
    Write-Host "✅ All checks passed!" -ForegroundColor Green
    exit 0
}
