$url = "https://storage.flutter-io.cn/flutter_infra_release/releases/stable/windows/flutter_windows_3.27.1-stable.zip"
$currentDir = Get-Location
$toolchainDir = Join-Path $currentDir "_toolchain"
$zipFile = Join-Path $toolchainDir "flutter.zip"
$flutterDir = Join-Path $toolchainDir "flutter"

# Create toolchain directory if it doesn't exist
if (!(Test-Path $toolchainDir)) {
    New-Item -ItemType Directory -Force -Path $toolchainDir | Out-Null
    Write-Host "Created directory: $toolchainDir"
}

# Check if flutter directory already exists
if (Test-Path (Join-Path $flutterDir "bin\flutter.bat")) {
    Write-Host "Flutter SDK seems to be already installed at $flutterDir"
    exit 0
}

# Download Flutter SDK using BITS
Write-Host "Downloading Flutter SDK from $url..."
try {
    Import-Module BitsTransfer
    Start-BitsTransfer -Source $url -Destination $zipFile -Priority Foreground
    Write-Host "Download complete."
} catch {
    Write-Error "Failed to download Flutter SDK: $_"
    exit 1
}

# Extract Flutter SDK
Write-Host "Extracting Flutter SDK..."
try {
    Expand-Archive -Path $zipFile -DestinationPath $toolchainDir -Force
    Write-Host "Extraction complete."
} catch {
    Write-Error "Failed to extract Flutter SDK: $_"
    exit 1
}

# Cleanup
if (Test-Path $zipFile) {
    Remove-Item $zipFile
}

Write-Host "Flutter SDK installed successfully."
