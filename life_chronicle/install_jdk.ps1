$url = "https://aka.ms/download-jdk/microsoft-jdk-17.0.9-windows-x64.zip"
$currentDir = Get-Location
$toolchainDir = Join-Path $currentDir "_toolchain"
$zipFile = Join-Path $toolchainDir "jdk.zip"
$jdkDir = Join-Path $toolchainDir "jdk-17"

Write-Host "Current Directory: $currentDir"
Write-Host "Toolchain Directory: $toolchainDir"

# Create toolchain directory if it doesn't exist
if (!(Test-Path $toolchainDir)) {
    New-Item -ItemType Directory -Force -Path $toolchainDir | Out-Null
    Write-Host "Created directory: $toolchainDir"
}

# Check if JDK is already installed
if (Test-Path (Join-Path $jdkDir "bin\java.exe")) {
    Write-Host "JDK seems to be already installed at $jdkDir"
    exit 0
}

# Download JDK
Write-Host "Downloading JDK from $url..."
try {
    Import-Module BitsTransfer
    Start-BitsTransfer -Source $url -Destination $zipFile -Priority Foreground
    Write-Host "Download complete."
} catch {
    Write-Error "Failed to download JDK: $_"
    exit 1
}

# Extract JDK
Write-Host "Extracting JDK..."
try {
    Expand-Archive -Path $zipFile -DestinationPath $toolchainDir -Force
    # Rename the extracted folder (it usually has version number) to 'jdk-17'
    $extractedFolder = Get-ChildItem -Path $toolchainDir -Directory | Where-Object { $_.Name -like "jdk-17*" } | Sort-Object Name -Descending | Select-Object -First 1
    if ($extractedFolder) {
        Rename-Item -Path $extractedFolder.FullName -NewName "jdk-17" -Force
    }
    Write-Host "Extraction complete."
} catch {
    Write-Error "Failed to extract JDK: $_"
    exit 1
}

# Cleanup
if (Test-Path $zipFile) {
    Remove-Item $zipFile
}

Write-Host "JDK installed successfully at $jdkDir"
