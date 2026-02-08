# OIDC Sample Application - Quick Start

このディレクトリには、OpenID Connect (OIDC) 認証のサンプルアプリケーションが含まれています。

## 📁 プロジェクト構成

```
oidc-sample/
├── oidc-client/              # フロントエンド (Vue.js + TypeScript)
│   ├── src/
│   │   ├── services/         # OIDC認証サービス
│   │   ├── views/            # ページコンポーネント
│   │   ├── router/           # ルーティング設定
│   │   └── style.css         # グローバルスタイル
│   ├── package.json
│   └── README.md
├── oidc_implementation_guide.md  # 実装ガイド
└── SETUP_GUIDE.md                # 詳細なセットアップ手順
```

## 🚀 クイックスタート

### 1. Keycloakの起動 (Docker)

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

1. `http://localhost:8082` にアクセス (admin/admin)
2. Realm作成: `myrealm`
3. Client作成: `oidc-client` (設定は `SETUP_GUIDE.md` 参照)
4. テストユーザー作成: `user` / `password`

### 3. フロントエンドの起動

```bash
cd oidc-client
npm install
npm run dev
```

アプリケーションは `http://localhost:8081` で起動します。

### 4. 動作確認

1. `http://localhost:8081` にアクセス
2. 「Keycloakでログイン」をクリック
3. `testuser` / `password` でログイン
4. ダッシュボードが表示されます

## 📖 ドキュメント

- **`oidc_implementation_guide.md`**: OIDC実装の概要と技術詳細
- **`SETUP_GUIDE.md`**: 詳細なセットアップ手順（Keycloak、Frontend、Backend）
- **`oidc-client/README.md`**: フロントエンドアプリケーションの詳細

## 🎯 主な機能

- ✅ **PKCE対応**: 認可コードの横取り攻撃を防止
- ✅ **State & Nonce**: CSRF攻撃とリプレイ攻撃を防止
- ✅ **自動検証**: `oidc-client-ts`による自動パラメータ検証
- ✅ **モダンUI**: グラスモーフィズム、グラデーション、アニメーション
- ✅ **TypeScript**: 型安全な実装

## 🔧 技術スタック

- **Frontend**: Vue 3 + TypeScript + Vite
- **Auth Library**: oidc-client-ts
- **Auth Provider**: Keycloak
- **Backend** (オプション): Spring Boot + OAuth2 Resource Server

## 📝 次のステップ

1. バックエンド (Spring Boot) のセットアップ → `SETUP_GUIDE.md` 参照
2. APIテスト機能の確認 → ダッシュボードの「バックエンドAPIをテスト」ボタン
3. カスタマイズ → `src/services/oidcService.ts` で設定変更

## 🆘 トラブルシューティング

問題が発生した場合は、`SETUP_GUIDE.md` の「トラブルシューティング」セクションを参照してください。

## 📄 ライセンス

MIT License
