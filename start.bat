@echo off
echo =====================================
echo Water Billing System - Starting...
echo =====================================
echo.

cd /d "%~dp0"

echo Checking Maven installation...
mvn --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Maven is not installed or not in PATH!
    echo Please install Maven from https://maven.apache.org/download.cgi
    pause
    exit /b 1
)

echo.
echo Installing dependencies...
call mvn clean install -q

if errorlevel 1 (
    echo ERROR: Failed to build project!
    pause
    exit /b 1
)

echo.
echo =====================================
echo Starting Water Billing System...
echo =====================================
echo.
echo Application will be available at:
echo http://localhost:8080
echo.
echo Default Admin Credentials:
echo Username: admin
echo Password: admin123
echo.
echo Press Ctrl+C to stop the server
echo =====================================
echo.

call mvn jetty:run
