#!/bin/bash

echo "===================================="
echo "Starting Keycloak"
echo "===================================="
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KEYCLOAK_PATH="$SCRIPT_DIR/../oidc-idp/keycloak-26.5.2/bin/kc.sh"

# Check if local Keycloak exists
if [ -f "$KEYCLOAK_PATH" ]; then
    echo "Found local Keycloak installation. Starting..."
    echo ""

    # Check if already running
    if netstat -ano 2>/dev/null | grep -q ':8082.*LISTENING'; then
        echo "Keycloak appears to be already running on port 8082."
        echo "If you need to restart, stop it first with: scripts/stop-keycloak.sh"
    else
        echo "Starting Keycloak on port 8082..."
        KC_BIN_DIR="$SCRIPT_DIR/../oidc-idp/keycloak-26.5.2/bin"

        # Convert to Windows path for cmd.exe
        WIN_PATH=$(cygpath -w "$KC_BIN_DIR" 2>/dev/null || echo "$KC_BIN_DIR" | sed 's|^/c/|C:/|' | sed 's|/|\\|g')

        # Start in new terminal window using cmd.exe
        cmd.exe /c start "Keycloak" cmd /k "cd /d \"$WIN_PATH\" && set KC_HTTP_PORT=8082 && kc.bat start-dev"

        echo ""
        echo "Keycloak is starting in a new window..."
        echo "Wait about 30 seconds for Keycloak to fully start."
    fi
else
    echo "Local Keycloak not found. Trying Docker..."
    echo ""

    # Keycloakコンテナが存在するか確認
    if docker ps -a --filter "name=keycloak" --format "{{.Names}}" | grep -q "keycloak"; then
        echo "Keycloak container exists. Starting..."
        docker start keycloak
        if [ $? -eq 0 ]; then
            echo "Keycloak container started successfully."
        else
            echo "Failed to start Keycloak container."
            exit 1
        fi
    else
        echo "Keycloak container does not exist. Creating and starting..."
        docker run -d \
          --name keycloak \
          -p 8082:8080 \
          -e KEYCLOAK_ADMIN=admin \
          -e KEYCLOAK_ADMIN_PASSWORD=admin \
          quay.io/keycloak/keycloak:latest \
          start-dev

        if [ $? -eq 0 ]; then
            echo "Keycloak container created and started successfully."
        else
            echo "Failed to create Keycloak container."
            exit 1
        fi
    fi
fi

echo ""
echo "===================================="
echo "Keycloak is starting..."
echo "===================================="
echo ""
echo "It may take 1-2 minutes to fully start."
echo "Access: http://localhost:8082"
echo "Admin: admin / admin"
echo ""
echo "Local version: Check console output or logs in oidc-idp/keycloak-26.5.2/data/"
echo "Docker version: docker logs -f keycloak"
echo ""
