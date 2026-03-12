@echo off
echo ====================================
echo OIDC Sample - Start All Services
echo ====================================
echo.

REM Get script directory and move to project root
cd /d "%~dp0.."

echo Starting services...
echo.

echo [1/4] Starting Main OIDC Server (localhost:8080)...
start "OIDC Server" cmd /k "cd /d "%~dp0..\main\oidc-server" && gradlew.bat bootRun"
timeout /t 3 /nobreak >nul

echo [2/4] Starting Main OIDC Client (localhost:8081)...
start "OIDC Client" cmd /k "cd /d "%~dp0..\main\oidc-client" && npm run dev"
timeout /t 3 /nobreak >nul

echo [3/4] Starting Exchange Server (127.0.0.1:8090)...
start "Exchange Server" cmd /k "cd /d "%~dp0..\other\exchange-server" && gradlew.bat bootRun"
timeout /t 3 /nobreak >nul

echo [4/4] Starting Exchange Client (127.0.0.1:8091)...
start "Exchange Client" cmd /k "cd /d "%~dp0..\other\exchange-client" && npm run dev"

echo.
echo ====================================
echo All services are starting...
echo ====================================
echo.
echo Services:
echo   - OIDC Server:      http://localhost:8080
echo   - OIDC Client:      http://localhost:8081
echo   - Exchange Server:  http://127.0.0.1:8090
echo   - Exchange Client:  http://127.0.0.1:8091
echo   - Keycloak:         http://localhost:8082 (Start manually)
echo.
echo Each service is running in a separate window.
echo.
echo Note: Start Keycloak manually in a separate command prompt:
echo   cd oidc-idp\keycloak-26.5.2\bin
echo   set KC_HTTP_PORT=8082
echo   kc.bat start-dev
echo.
echo To stop services, close each window or use stop-all.bat
echo.
pause
