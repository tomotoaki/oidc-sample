# 🛡️ OIDC Client - Frontend Sample Application

このアプリケーションは、OpenID Connect (OIDC) 認証のフロントエンドサンプルです。**Authorization Code Flow with PKCE** を使用して、セキュアな認証を実装しています。

## ✨ 特徴

- **Vue 3 + TypeScript**: 最新のVue.jsとTypeScriptで構築
- **PKCE対応**: 認可コードの横取り攻撃を防止
- **State & Nonce**: CSRF攻撃とリプレイ攻撃を防止
- **モダンUI**: グラスモーフィズム、グラデーション、アニメーションを活用したプレミアムデザイン
- **oidc-client-ts**: セキュリティパラメータの自動生成・検証

## 🚀 セットアップ

### 1. 依存関係のインストール

```bash
npm install
```

### 2. Keycloakの設定

Keycloakを `http://localhost:8082` で起動し、以下の設定を行ってください:

| 設定項目                  | 値                        |
| ------------------------- | ------------------------- |
| **Client ID**             | `vue-client`              |
| **Client Protocol**       | `openid-connect`          |
| **Access Type**           | `public`                  |
| **Standard Flow Enabled** | `ON`                      |
| **Valid Redirect URIs**   | `http://localhost:8081/*` |
| **Web Origins**           | `http://localhost:8081`   |
| **PKCE Challenge Method** | `S256` (Advancedタブ内)   |

### 3. OIDC設定の更新

`src/services/oidcService.ts` の `authority` を、Keycloakのrealm URLに合わせて更新してください:

```typescript
authority: "http://localhost:8082/realms/myrealm", // 実際のrealm名に変更
```

### 4. 開発サーバーの起動

```bash
npm run dev
```

アプリケーションは `http://localhost:8081` で起動します。

## 📁 プロジェクト構成

```
oidc-client/
├── src/
│   ├── services/
│   │   └── oidcService.ts      # OIDC認証サービス
│   ├── views/
│   │   ├── Home.vue            # ホームページ（ログイン画面）
│   │   ├── Callback.vue        # OIDC コールバック処理
│   │   └── Dashboard.vue       # ダッシュボード（認証後）
│   ├── router/
│   │   └── index.ts            # Vue Router設定
│   ├── App.vue                 # メインアプリケーション
│   ├── main.ts                 # エントリーポイント
│   └── style.css               # グローバルスタイル
├── index.html
├── package.json
├── vite.config.ts
└── tsconfig.json
```

## 🔐 認証フロー

1. **ログイン開始**: ユーザーが「ログイン」ボタンをクリック
2. **認可リクエスト**: `state`, `nonce`, `code_challenge` を生成してKeycloakへリダイレクト
3. **ユーザー認証**: Keycloakでユーザーがログイン
4. **認可コード返却**: Keycloakが認可コードと `state` を返却
5. **トークン交換**: `code` と `code_verifier` を送信してアクセストークンを取得
6. **検証**: `state`, `nonce`, PKCEが自動検証される
7. **ダッシュボード**: 認証成功後、ユーザー情報を表示

## 🎨 デザインシステム

このアプリケーションは、以下のデザイン原則に基づいています:

- **カラーパレット**: HSLベースの調和のとれた配色
- **タイポグラフィ**: Google Fonts (Inter)
- **グラスモーフィズム**: 半透明の背景とぼかし効果
- **グラデーション**: 鮮やかなグラデーション
- **アニメーション**: スムーズなトランジションとホバーエフェクト

## 🧪 バックエンドAPIのテスト

ダッシュボードには「バックエンドAPIをテスト」ボタンがあります。これは `http://localhost:8080/api/user` にアクセストークンを付けてリクエストを送信します。

バックエンド（Spring Boot）が起動していない場合はエラーになります。

## 📚 使用技術

- **Vue 3**: プログレッシブJavaScriptフレームワーク
- **TypeScript**: 型安全性
- **Vite**: 高速ビルドツール
- **Vue Router**: ルーティング
- **oidc-client-ts**: OIDC認証ライブラリ

## 🔧 ビルド

本番用ビルドを作成:

```bash
npm run build
```

ビルドされたファイルは `dist/` ディレクトリに出力されます。

## 📝 ライセンス

このサンプルアプリケーションはMITライセンスです。
