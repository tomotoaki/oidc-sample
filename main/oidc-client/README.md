# OIDC Client

Main DomainのフロントエンドSPAです。OIDC認証フロー（Authorization Code Flow with PKCE）を実装しています。

## このコンポーネントについて

Main Domain（localhost:8081）で動作するVue.jsアプリケーションです。Keycloakと連携してユーザー認証を行い、oidc-serverのProtected APIを呼び出します。

### 主な機能

- OIDC認証フロー（Authorization Code Flow with PKCE）
- セキュリティパラメータの自動生成・検証（state、nonce、code_challenge）
- JWT（Access Token）の管理
- Protected APIの呼び出し（Authorization ヘッダー付与）
- Token Exchange APIの呼び出し（Other Domainへの遷移）

### 技術スタック

- Vue 3（Composition API）
- TypeScript
- Vue Router
- oidc-client-ts（OIDC認証ライブラリ）
- Vite（ビルドツール）

## クイックスタート

```bash
# 依存関係インストール
npm install

# 開発サーバー起動
npm run dev
```

アプリケーションは http://localhost:8081 で起動します。

> **詳細な設定手順**: [QUICKSTART.md](../../QUICKSTART.md) を参照

## ディレクトリ構成

```
oidc-client/
├── src/
│   ├── services/          # OIDC認証・API呼び出しロジック
│   │   ├── oidcService.ts
│   │   └── apiService.ts
│   ├── views/             # ページコンポーネント
│   │   ├── Home.vue
│   │   ├── Callback.vue
│   │   └── Dashboard.vue
│   ├── router/            # ルーティング設定
│   │   └── index.ts
│   ├── App.vue
│   └── main.ts
├── public/
├── index.html
├── package.json
├── vite.config.ts
└── tsconfig.json
```

## 提供するページ

| ページ | パス | 説明 |
|-------|------|------|
| Home | `/` | ログイン前のトップページ |
| Callback | `/callback` | OIDC認証後のコールバック処理 |
| Dashboard | `/dashboard` | ログイン後のダッシュボード（Protected） |

## 関連ドキュメント

- [プロジェクト全体の概要](../../README.md)
- [セットアップガイド](../../QUICKSTART.md)
- [実装要件](../../oidc_implementation_guide.md)
