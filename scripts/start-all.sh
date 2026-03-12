#!/bin/bash

echo "===================================="
echo "OIDC Sample - Start All Services"
echo "===================================="
echo ""

# 作業ディレクトリを取得（スクリプトの親ディレクトリ＝プロジェクトルート）
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$SCRIPT_DIR"

# ログディレクトリを作成
mkdir -p logs

echo "Starting services..."
echo ""

# Main OIDC Server
echo "[1/4] Starting Main OIDC Server (localhost:8080)..."
cd main/oidc-server
./gradlew bootRun > ../../logs/oidc-server.log 2>&1 &
cd "$SCRIPT_DIR"
sleep 3

# Main OIDC Client
echo "[2/4] Starting Main OIDC Client (localhost:8081)..."
cd main/oidc-client
npm run dev > ../../logs/oidc-client.log 2>&1 &
cd "$SCRIPT_DIR"
sleep 3

# Exchange Server
echo "[3/4] Starting Exchange Server (127.0.0.1:8090)..."
cd other/exchange-server
./gradlew bootRun > ../../logs/exchange-server.log 2>&1 &
cd "$SCRIPT_DIR"
sleep 3

# Exchange Client
echo "[4/4] Starting Exchange Client (127.0.0.1:8091)..."
cd other/exchange-client
npm run dev > ../../logs/exchange-client.log 2>&1 &
cd "$SCRIPT_DIR"
sleep 2
cd "$SCRIPT_DIR"

echo ""
echo "===================================="
echo "All services started!"
echo "===================================="
echo ""
echo "Services:"
echo "  - OIDC Server:      http://localhost:8080"
echo "  - OIDC Client:      http://localhost:8081"
echo "  - Exchange Server:  http://127.0.0.1:8090"
echo "  - Exchange Client:  http://127.0.0.1:8091"
echo "  - Keycloak:         http://localhost:8082 (Start manually)"
echo ""
echo "Note: Start Keycloak manually in a separate terminal:"
echo "  cd oidc-idp/keycloak-26.5.2/bin"
echo "  KC_HTTP_PORT=8082 ./kc.sh start-dev"
echo ""
echo "Logs are available in the 'logs' directory."
echo "To view logs in real-time:"
echo "  tail -f logs/oidc-server.log"
echo "  tail -f logs/exchange-server.log"
echo ""
echo "To stop all services, run: scripts/stop-all.sh"
echo ""
