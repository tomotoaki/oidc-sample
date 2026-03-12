#!/bin/bash

echo "===================================="
echo "OIDC Sample - Stop All Services"
echo "===================================="
echo ""

# 作業ディレクトリを取得（スクリプトの親ディレクトリ=プロジェクトルート）
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$SCRIPT_DIR"

echo "Stopping services by port number..."
echo ""

# ポート8080 (OIDC Server)
echo "Stopping OIDC Server (port 8080)..."
PID=$(netstat -ano | grep ":8080 " | grep "LISTENING" | awk '{print $5}' | head -1)
if [ -n "$PID" ]; then
    taskkill //PID $PID //F 2>/dev/null && echo "  Stopped (PID: $PID)." || echo "  Failed to stop."
else
    echo "  Not running."
fi

# ポート8081 (OIDC Client)
echo "Stopping OIDC Client (port 8081)..."
PID=$(netstat -ano | grep ":8081 " | grep "LISTENING" | awk '{print $5}' | head -1)
if [ -n "$PID" ]; then
    taskkill //PID $PID //F 2>/dev/null && echo "  Stopped (PID: $PID)." || echo "  Failed to stop."
else
    echo "  Not running."
fi

# ポート8090 (Exchange Server)
echo "Stopping Exchange Server (port 8090)..."
PID=$(netstat -ano | grep ":8090 " | grep "LISTENING" | awk '{print $5}' | head -1)
if [ -n "$PID" ]; then
    taskkill //PID $PID //F 2>/dev/null && echo "  Stopped (PID: $PID)." || echo "  Failed to stop."
else
    echo "  Not running."
fi

# ポート8091 (Exchange Client)
echo "Stopping Exchange Client (port 8091)..."
PID=$(netstat -ano | grep ":8091 " | grep "LISTENING" | awk '{print $5}' | head -1)
if [ -n "$PID" ]; then
    taskkill //PID $PID //F 2>/dev/null && echo "  Stopped (PID: $PID)." || echo "  Failed to stop."
else
    echo "  Not running."
fi

# PIDファイルのクリーンアップ
rm -f logs/*.pid 2>/dev/null

echo ""
echo "===================================="
echo "All services stopped."
echo "===================================="
echo ""
echo "Note: To stop Keycloak, press Ctrl+C in its terminal."
echo ""
