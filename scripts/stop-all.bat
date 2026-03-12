@echo off
echo ====================================
echo OIDC Sample - Stop All Services
echo ====================================
echo.

echo Stopping services by window title...
echo.

echo Stopping OIDC Server...
taskkill /FI "WINDOWTITLE eq OIDC Server*" /F 2>nul

echo Stopping OIDC Client...
taskkill /FI "WINDOWTITLE eq OIDC Client*" /F 2>nul

echo Stopping Exchange Server...
taskkill /FI "WINDOWTITLE eq Exchange Server*" /F 2>nul

echo Stopping Exchange Client...
taskkill /FI "WINDOWTITLE eq Exchange Client*" /F 2>nul

echo.
echo Cleaning up processes on ports...
echo.

REM Stop by port 8080 (OIDC Server)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8080"') do (
    taskkill /PID %%a /F 2>nul
)

REM Stop by port 8081 (OIDC Client)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8081"') do (
    taskkill /PID %%a /F 2>nul
)

REM Stop by port 8090 (Exchange Server)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8090"') do (
    taskkill /PID %%a /F 2>nul
)

REM Stop by port 8091 (Exchange Client)
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":8091"') do (
    taskkill /PID %%a /F 2>nul
)

echo.
echo ====================================
echo All services stopped.
echo ====================================
echo.
echo Note: To stop Keycloak, press Ctrl+C in its command prompt.
echo.
pause
