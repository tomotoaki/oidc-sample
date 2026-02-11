# OIDC Client (Frontend)

OIDC認証のフロントエンドサンプルです。Authorization Code Flow with PKCEを使用します。

## 前提条件

- Node.js 18以上
- Keycloak が `http://localhost:8082` で稼働していること

## セットアップ

1. 依存関係のインストール

```bash
npm install
```

2. Keycloakのクライアント設定

- Client ID: `oidc-client`
- Client Protocol: `openid-connect`
- Client authentication: `ON` (Confidential)
- Standard Flow Enabled: `ON`
- Valid Redirect URIs: `http://localhost:8081/*`
- Post Logout Redirect URIs: `http://localhost:8081/`
- Web Origins: `http://localhost:8081`
- PKCE Challenge Method: `S256` (Advancedタブ)

3. OIDC設定の更新

`src/services/oidcService.ts` の `authority` と `client_secret` を実環境に合わせて更新してください。

```typescript
authority: "http://localhost:8082/realms/myrealm",
client_id: "oidc-client",
client_secret: "...",
```

## 起動方法

```bash
npm run dev
```

アプリケーションは `http://localhost:8081` で起動します。

## API連携

`src/services/apiService.ts` を通じて、バックエンド（oidc-server）へアクセスします。

- 公開API: `GET /api/public/hello`
- 保護API: `GET /api/protected/user` / `GET /api/protected/dashboard`

## プロジェクト構成

```
oidc-client/
├── src/
│   ├── services/
│   │   ├── oidcService.ts
│   │   └── apiService.ts
│   ├── views/
│   │   ├── Home.vue
│   │   ├── Callback.vue
│   │   └── Dashboard.vue
│   ├── router/
│   │   └── index.ts
│   ├── App.vue
│   ├── main.ts
│   └── style.css
├── index.html
├── package.json
├── vite.config.ts
└── tsconfig.json
```

## 補足

全体の手順はルートの `SETUP_GUIDE.md` も参照してください。
