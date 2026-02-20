$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.27.1-stable.zip"
$toolchainDir = "D:\trae\人生编年国际\life_chronicle\_toolchain"
$zipFile = "$toolchainDir\flutter.zip"

# Create toolchain directory if it doesn't exist
if (!(Test-Path $toolchainDir)) {
    New-Item -ItemType Directory -Force -Path $toolchainDir | Out-Null
    Write-Host "Created directory: $toolchainDir"
}

# Check if flutter directory already exists
if (Test-Path "$toolchainDir\flutter\bin\flutter.bat") {
    Write-Host "Flutter SDK seems to be already installed at $toolchainDir\flutter"
    exit 0
}

# Download Flutter SDK
Write-Host "Downloading Flutter SDK from $url..."
try {
    Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
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
