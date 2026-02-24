@echo off
setlocal enabledelayedexpansion

set KEYSTORE_FILE=life-chronicle-release.jks
set KEY_ALIAS=life-chronicle
set VALIDITY=10000

echo ========================================
echo   Life Chronicle - Release Keystore
echo ========================================
echo.

set /p STORE_PASSWORD="Enter store password (min 6 chars): "
if "%STORE_PASSWORD%"=="" (
    echo Error: Password cannot be empty
    pause
    exit /b 1
)

set /p KEY_PASSWORD="Enter key password (min 6 chars): "
if "%KEY_PASSWORD%"=="" (
    echo Error: Password cannot be empty
    pause
    exit /b 1
)

echo.
echo Generating keystore file...
echo.

keytool -genkey -v ^
    -keystore %KEYSTORE_FILE% ^
    -keyalg RSA ^
    -keysize 2048 ^
    -validity %VALIDITY% ^
    -alias %KEY_ALIAS% ^
    -storepass %STORE_PASSWORD% ^
    -keypass %KEY_PASSWORD% ^
    -dname "CN=Life Chronicle, OU=Development, O=Suliuzhe, L=Unknown, ST=Unknown, C=CN"

if %ERRORLEVEL% neq 0 (
    echo.
    echo Error: Keystore generation failed. Please check if Java JDK is installed.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Keystore generated successfully!
echo ========================================
echo.
echo File location: %CD%\%KEYSTORE_FILE%
echo.

echo Creating key.properties file...
(
    echo storePassword=%STORE_PASSWORD%
    echo keyPassword=%KEY_PASSWORD%
    echo keyAlias=%KEY_ALIAS%
    echo storeFile=%KEYSTORE_FILE%
) > key.properties

echo key.properties file created!
echo.
echo ========================================
echo   Important Notes
echo ========================================
echo.
echo 1. Keep the keystore file and passwords safe
echo 2. Do NOT commit key.properties and .jks files to version control
echo 3. Backup the keystore file to a secure location
echo 4. If you lose the keystore, you cannot update the published app
echo.

pause
