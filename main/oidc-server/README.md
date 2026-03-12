# OIDC Server

Main DomainのバックエンドAPIサーバーです。OAuth2 Resource Serverとして動作し、KeycloakのJWTを検証します。

## このコンポーネントについて

Main Domain（localhost:8080）で動作するSpring Bootアプリケーションです。oidc-clientから送信されるJWTを検証し、Protected APIを提供します。

### 主な機能

- JWT検証（署名、有効期限、発行者、オーディエンス）
- Public APIの提供（認証不要）
- Protected APIの提供（JWT認証必須）
- CORS設定（Frontend URLからのアクセス許可）
- リソース保護（Spring Security）

### 技術スタック

- Spring Boot 3.4.2
- Spring Security 6
- OAuth2 Resource Server
- Java 21
- Gradle

## クイックスタート

```bash
# ビルド
./gradlew build

# 起動
./gradlew bootRun
```

> Windows: `gradlew.bat bootRun`

アプリケーションは http://localhost:8080 で起動します。

> **詳細な設定手順**: [QUICKSTART.md](../../QUICKSTART.md) を参照

## ディレクトリ構成

```
oidc-server/
├── src/
│   ├── main/
│   │   ├── java/com/example/oidcserver/
│   │   │   ├── OidcServerApplication.java
│   │   │   ├── config/
│   │   │   │   └── SecurityConfig.java
│   │   │   └── controller/
│   │   │       └── ApiController.java
│   │   └── resources/
│   │       └── application.yml
│   └── test/
├── build.gradle
└── settings.gradle
```

## 提供するAPI

| エンドポイント | メソッド | 認証 | 説明 |
|--------------|---------|------|------|
| `/api/public/hello` | GET | 不要 | 動作確認用 Public API |
| `/api/protected/user` | GET | 必要 | ユーザー情報取得 |
| `/api/protected/dashboard` | GET | 必要 | ダッシュボードデータ取得 |

### 認証方法

Protected APIには、以下のヘッダーを付与してください：

```
Authorization: Bearer <access_token>
```

## 関連ドキュメント

- [プロジェクト全体の概要](../../README.md)
- [セットアップガイド](../../QUICKSTART.md)
- [実装要件](../../oidc_implementation_guide.md)
