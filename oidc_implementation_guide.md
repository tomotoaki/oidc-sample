# 🛡️ PKCE対応 OIDC実装ガイド

この構成では、公共クライアント（Vue.js）において推奨される **Authorization Code Flow with PKCE** を採用し、`state`, `nonce`, `code_challenge` を活用してセキュリティを最大化します。

---

## 1. Keycloak（IDプロバイダー）の設定

Keycloakの管理コンソールで、クライアントを以下のように構成します。

| 設定項目                  | 値                        | 備考                                 |
| ------------------------- | ------------------------- | ------------------------------------ |
| **Client ID**             | `vue-client`              | 任意。Vue側と一致させる              |
| **Client Protocol**       | `openid-connect`          |                                      |
| **Access Type**           | `public`                  | ブラウザ実行のためSecretは保持しない |
| **Standard Flow Enabled** | `ON`                      | 認可コードフローを有効化             |
| **Valid Redirect URIs**   | `http://localhost:8080/*` | Vueの待ち受けURL                     |
| **Web Origins**           | `http://localhost:8080`   | CORS許可設定                         |
| **PKCE Challenge Method** | `S256`                    | **必須設定** (Advancedタブ内)        |

---

## 2. Vue.js (Frontend) 実装

`oidc-client-ts` を使用します。このライブラリは、設定を行うだけで `state`, `nonce`, `code_challenge` の生成・検証を自動で行います。

### 依存関係のインストール

```bash
npm install oidc-client-ts

```

### OIDC 設定ファイル (`oidcService.ts`)

```typescript
import { UserManager, WebStorageStateStore } from "oidc-client-ts";

const settings = {
  authority: "http://<keycloak-url>/realms/<realm-name>",
  client_id: "vue-client",
  redirect_uri: "http://localhost:8080/callback",
  response_type: "code", // 認可コードフロー + PKCE を指定
  scope: "openid profile email",
  userStore: new WebStorageStateStore({ store: window.localStorage }),
};

export const userManager = new UserManager(settings);

// ログイン実行
export const login = () => userManager.signinRedirect();

// コールバック処理 (state, nonce, PKCEの自動検証)
export const handleCallback = () => userManager.signinRedirectCallback();

```

---

## 3. Spring Boot (Backend) 実装

バックエンドは「リソースサーバー」として動作させ、Vueから送られてくる `access_token` (JWT) の正当性を検証します。

### 依存関係 (`build.gradle`)

```gradle
implementation 'org.springframework.boot:spring-boot-starter-oauth2-resource-server'

```

### 設定 (`application.yml`)

```yaml
spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://<keycloak-url>/realms/<realm-name>

```

### セキュリティ設定クラス

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .anyRequest().authenticated() // 全APIを保護
            )
            .oauth2ResourceServer(oauth -> oauth.jwt(Customizer.withDefaults()));
        return http.build();
    }
}

```

---

## 🔐 セキュリティパラメータの役割まとめ

| パラメータ           | 役割                                     | 検証者       |
| -------------------- | ---------------------------------------- | ------------ |
| **`state`**          | CSRF（ログイン強要）攻撃の防止           | **Vue.js**   |
| **`nonce`**          | リプレイ攻撃（トークンの使い回し）の防止 | **Vue.js**   |
| **`code_challenge`** | 認可コードの横取り防止（PKCE）           | **Keycloak** |

---

## 4. 処理フロー確認

1. **認可リクエスト**: Vueが `state`, `nonce`, `code_challenge` を生成しKeycloakへリダイレクト。
2. **ログイン**: ユーザーがKeycloak上で認証。
3. **認可コード返却**: Keycloakが `code` と `state` をVueに返す。
4. **トークン交換**: Vueが `code` と `code_verifier` (challengeの元ネタ) をKeycloakへ送信。
5. **検証**: KeycloakがPKCEの一致を確認し、アクセストークンを返却。
6. **APIコール**: Vueが `Authorization: Bearer <token>` を付けてSpring Bootへリクエスト。
7. **トークン検証**: Spring BootがJWTの署名を検証。
