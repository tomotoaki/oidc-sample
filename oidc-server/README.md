# OIDC Server (Backend)

KeycloakのJWTを検証するOAuth2リソースサーバーです。

## 前提条件

- Java 21以上
- Gradle 9.x以上
- Keycloak が `http://localhost:8082` で稼働していること

## 起動方法

```bash
./gradlew bootRun
```

Windowsの場合:

```cmd
gradlew.bat bootRun
```

アプリケーションは `http://localhost:8080` で起動します。

## APIエンドポイント

- 公開API: `GET /api/public/hello`
- 保護API: `GET /api/protected/user`
- 保護API: `GET /api/protected/dashboard`

## 認証方法

保護されたエンドポイントには以下のヘッダーを付与してください。

```
Authorization: Bearer <access_token>
```

## 設定

`src/main/resources/application.yml` で以下を設定できます。

- `server.port`
- `spring.security.oauth2.resourceserver.jwt.issuer-uri`
- `cors.allowed-origins`

## 補足

全体の手順はルートの `SETUP_GUIDE.md` も参照してください。
