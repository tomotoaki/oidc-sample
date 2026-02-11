# OIDC Server (Spring Boot Backend)

このプロジェクトは、Keycloakを認証プロバイダーとして使用するOAuth2リソースサーバーです。

## 📋 前提条件

- Java 17以上
- Gradle 8.x以上
- Keycloak が `http://localhost:8082` で稼働していること

## 🚀 起動方法

### Gradleを使用する場合

```bash
./gradlew bootRun
```

Windowsの場合:
```cmd
gradlew.bat bootRun
```

アプリケーションは `http://localhost:8080` で起動します。

## 📡 APIエンドポイント

### 公開エンドポイント（認証不要）

- `GET /api/public/hello` - 公開テストエンドポイント

### 保護されたエンドポイント（認証必要）

- `GET /api/protected/user` - ユーザー情報取得
- `GET /api/protected/dashboard` - ダッシュボードデータ取得

## 🔐 認証方法

保護されたエンドポイントにアクセスする際は、以下のヘッダーを付与してください：

```
Authorization: Bearer <access_token>
```

`<access_token>` は、Keycloakから発行されたJWTトークンです。

## 🧪 テスト方法

### 公開エンドポイントのテスト

```bash
curl http://localhost:8080/api/public/hello
```

### 保護されたエンドポイントのテスト

```bash
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     http://localhost:8080/api/protected/user
```

## ⚙️ 設定

`src/main/resources/application.yml` で以下の設定を変更できます：

- **ポート番号**: `server.port`
- **Keycloak URL**: `spring.security.oauth2.resourceserver.jwt.issuer-uri`
- **CORS設定**: `cors.allowed-origins`

## 📝 主要ファイル

- `OidcServerApplication.java` - メインアプリケーションクラス
- `SecurityConfig.java` - セキュリティ設定（JWT検証、CORS）
- `ApiController.java` - サンプルAPIエンドポイント
- `application.yml` - アプリケーション設定

## 🔧 トラブルシューティング

### Keycloakに接続できない場合

1. Keycloakが `http://localhost:8082` で稼働していることを確認
2. `application.yml` の `issuer-uri` がKeycloakのrealm URLと一致していることを確認
3. ログレベルを `DEBUG` に設定して詳細を確認

### CORS エラーが発生する場合

`application.yml` の `cors.allowed-origins` にフロントエンドのURLが含まれているか確認してください。
