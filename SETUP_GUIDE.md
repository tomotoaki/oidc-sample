# OIDC Sample Setup Guide

このガイドでは、OIDC認証のサンプルアプリケーション全体をセットアップする手順を説明します。

## 前提条件

- Node.js 18以上
- Java 21以上
- Docker (Keycloak用、またはローカルインストール)

## アーキテクチャ概要

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   Frontend      │         │   Keycloak      │         │   Backend       │
│   (Vue.js)      │◄───────►│   (Auth)        │◄───────►│   (Spring Boot) │
│   Port: 8081    │         │   Port: 8082    │         │   Port: 8080    │
└─────────────────┘         └─────────────────┘         └─────────────────┘
```

## 1. Keycloakのセットアップ

### Dockerを使用する場合

```bash
docker run -d \
  --name keycloak \
  -p 8082:8080 \
  -e KEYCLOAK_ADMIN=admin \
  -e KEYCLOAK_ADMIN_PASSWORD=admin \
  quay.io/keycloak/keycloak:latest \
  start-dev
```

### 管理コンソールにアクセス

1. `http://localhost:8082` を開く
2. ユーザー名: `admin` / パスワード: `admin`

### Realmの作成

1. 左上の「Master」をクリックし「Create Realm」
2. Realm名: `myrealm`
3. 「Create」をクリック

### Clientの作成

1. 左メニューから「Clients」→「Create client」
2. 以下の設定を入力

General Settings:
- Client type: `OpenID Connect`
- Client ID: `oidc-client`

Capability config:
- Client authentication: `ON` (Confidential)
- Authorization: `OFF`
- Authentication flow:
  - Standard flow: `ON`
  - Direct access grants: `ON`
  - Implicit flow: `OFF`

Login settings:
- Valid redirect URIs: `http://localhost:8081/*`
- Valid post logout redirect URIs: `http://localhost:8081/`
- Web origins: `http://localhost:8081`

3. 「Save」をクリック

### Client Secretの取得

1. 「Credentials」タブを開く
2. 「Client Secret」をコピー
3. `oidc-client/src/services/oidcService.ts` の `client_secret` に設定

### PKCE設定

1. 作成したクライアント (`oidc-client`) を開く
2. 「Advanced」タブを開く
3. 「Proof Key for Code Exchange Code Challenge Method」を `S256` に設定
4. 「Save」をクリック

### テストユーザーの作成

1. 左メニューから「Users」→「Add user」
2. Username: `testuser`
3. 「Create」をクリック
4. 「Credentials」タブ → 「Set password」
5. Password: `password`
6. Temporary: `OFF`
7. 「Save」をクリック

## 2. Frontendのセットアップ

### 依存関係のインストール

```bash
cd oidc-client
npm install
```

### OIDC設定の確認

`oidc-client/src/services/oidcService.ts` を開き、`authority` が正しいか確認します。

```typescript
authority: "http://localhost:8082/realms/myrealm",
```

### 開発サーバーの起動

```bash
npm run dev
```

アプリケーションは `http://localhost:8081` で起動します。

## 3. Backend (Spring Boot) のセットアップ

### アプリケーションの起動

```bash
cd oidc-server
./gradlew bootRun
```

### 設定の確認

`oidc-server/src/main/resources/application.yml` で `issuer-uri` を確認してください。

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8082/realms/myrealm
```

## 4. 動作確認

### 1. サービス稼働の確認

- Keycloak: `http://localhost:8082`
- Frontend: `http://localhost:8081`
- Backend: `http://localhost:8080`

### 2. フロントエンドでログイン

1. `http://localhost:8081` にアクセス
2. 「Keycloakでログイン」ボタンをクリック
3. Username: `testuser` / Password: `password` でログイン
4. ダッシュボードにリダイレクトされる

### 3. バックエンドAPIのテスト

ダッシュボードで以下のボタンを実行し、APIレスポンスを確認します。

- Public API
- User API
- Dashboard API

## トラブルシューティング

### Keycloakに接続できない

- Dockerコンテナが起動しているか確認: `docker ps`
- ポート8082が使用されているか確認

### CORS エラー

- Keycloakの「Web origins」設定を確認
- Backendの `cors.allowed-origins` を確認

### トークン検証エラー

- `application.yml` の `issuer-uri` を確認
- Keycloakのrealm名が一致しているか確認

### PKCE エラー

- Keycloakクライアントの「Advanced」タブで `S256` が設定されているか確認

## 参考資料

- OpenID Connect Specification: https://openid.net/specs/openid-connect-core-1_0.html
- PKCE (RFC 7636): https://tools.ietf.org/html/rfc7636
- Keycloak Documentation: https://www.keycloak.org/documentation
- oidc-client-ts: https://github.com/authts/oidc-client-ts
