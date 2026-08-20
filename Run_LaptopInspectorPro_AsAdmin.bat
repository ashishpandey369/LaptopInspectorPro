@echo off
setlocal
cd /d "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

title LaptopInspectorPro
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0LaptopInspector.ps1"

if errorlevel 1 (
    echo.
    echo LaptopInspectorPro exited with an error.
    pause
)
endlocal
