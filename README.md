# OIDC Sample Application

OIDC (Authorization Code Flow with PKCE) のサンプル構成です。フロントエンド、バックエンド、Keycloakの最小構成で動作確認できます。

## プロジェクト構成

```
oidc-sample/
├── oidc-client/                # Frontend (Vue 3 + TypeScript)
├── oidc-server/                # Backend (Spring Boot Resource Server)
├── oidc-idp/                   # Keycloak
├── oidc_implementation_guide.md
└── SETUP_GUIDE.md
```

## クイックスタート

### 1. Keycloakの起動

Dockerを使用する場合:

```bash
docker run -d \
  --name keycloak \
  -p 8082:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:latest \
  start-dev
```

### 2. Keycloakの設定

- 管理コンソール: `http://localhost:8082` (admin/admin)
- Realm: `myrealm`
- Client: `oidc-client`
- テストユーザー: `testuser` / `password`

詳細は [SETUP_GUIDE.md](SETUP_GUIDE.md) を参照してください。

### 3. バックエンドの起動

```bash
cd oidc-server
./gradlew bootRun
```

### 4. フロントエンドの起動

```bash
cd oidc-client
npm install
npm run dev
```

起動後、以下のURLにアクセスできることを確認してください。

- Backend: `http://localhost:8080`
- Frontend: `http://localhost:8081`
- Keycloak: `http://localhost:8082`

## ドキュメント

- [SETUP_GUIDE.md](SETUP_GUIDE.md): 全体のセットアップ手順
- [oidc_implementation_guide.md](oidc_implementation_guide.md): 実装の技術解説
- [oidc-client/README.md](oidc-client/README.md): フロントエンドの詳細
- [oidc-server/README.md](oidc-server/README.md): バックエンドの詳細
