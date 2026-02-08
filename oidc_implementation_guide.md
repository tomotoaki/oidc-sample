# 🛡️ PKCE対応 OIDC実装ガイド

この構成では、公共クライアント（Vue.js）において推奨される **Authorization Code Flow with PKCE** を採用し、`state`, `nonce`, `code_challenge` を活用してセキュリティを最大化します。

---

## 1. 前提

### ポート構成

このサンプルでは以下のポート構成を前提とします。

| Role         | Service     | Port   | Base URL                |
| :----------- | :---------- | :----- | :---------------------- |
| **Backend**  | Spring Boot | `8080` | `http://localhost:8080` |
| **Frontend** | Vue.js App  | `8081` | `http://localhost:8081` |
| **Auth**     | Keycloak    | `8082` | `http://localhost:8082` |

Keycloakはデフォルトで8080を使用しますが、Spring Bootと競合するため `8082` に変更して起動してください。
Dockerを使用する場合は `docker run -p 8082:8080 ...` のようにマッピングしてください。

### セキュリティパラメータの役割

| パラメータ           | 役割                                     | 検証者       |
| -------------------- | ---------------------------------------- | ------------ |
| **`state`**          | CSRF（ログイン強要）攻撃の防止           | **Vue.js**   |
| **`nonce`**          | リプレイ攻撃（トークンの使い回し）の防止 | **Vue.js**   |
| **`code_challenge`** | 認可コードの横取り防止（PKCE）           | **Keycloak** |

---

## 2. Keycloak（IDプロバイダー）の設定

Keycloakの管理コンソールで、クライアントを以下のように構成します。
※以下、Keycloakは `http://localhost:8082` で稼働していると仮定します。

| 設定項目                  | 値                        | 備考                          |
| ------------------------- | ------------------------- | ----------------------------- |
| **Client ID**             | `oidc-client`             | 任意。Vue側と一致させる       |
| **Client Protocol**       | `openid-connect`          |                               |
| **Access Type**           | `confidential`            | Client Secretを使用           |
| **Standard Flow Enabled** | `ON`                      | 認可コードフローを有効化      |
| **Valid Redirect URIs**   | `http://localhost:8081/*` | Vueの待ち受けURL              |
| **Post Logout Redirect**  | `http://localhost:8081/`  | ログアウト後の戻り先          |
| **Web Origins**           | `http://localhost:8081`   | CORS許可設定                  |
| **PKCE Challenge Method** | `S256`                    | **必須設定** (Advancedタブ内) |

---

## 3. Vue.js (Frontend) 実装

`oidc-client-ts` を使用します。このライブラリは、設定を行うだけで `state`, `nonce`, `code_challenge` の生成・検証を自動で行います。

### 依存関係のインストール

```bash
npm install oidc-client-ts

```

### OIDC 設定ファイル (`oidcService.ts`)

```typescript
import { UserManager, WebStorageStateStore } from "oidc-client-ts";

const settings = {
  authority: "http://localhost:8082/realms/myrealm", 
  client_id: "oidc-client",
  client_secret: "...", // Confidential Clientの場合
  redirect_uri: "http://localhost:8081/callback",
  post_logout_redirect_uri: "http://localhost:8081/",
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

## 4. Spring Boot (Backend) 実装

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
          issuer-uri: http://localhost:8082/realms/<realm-name> # 例: http://localhost:8082/realms/myrealm

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

## 5. 処理フロー確認

1. **認可リクエスト**: Vueが `state`, `nonce`, `code_challenge` を生成しKeycloakへリダイレクト。
2. **ログイン**: ユーザーがKeycloak上で認証。
3. **認可コード返却**: Keycloakが `code` と `state` をVueに返す。
4. **トークン交換**: Vueが `code` と `code_verifier` (challengeの元ネタ) をKeycloakへ送信。
5. **検証**: KeycloakがPKCEの一致を確認し、アクセストークンを返却。
6. **APIコール**: Vueが `Authorization: Bearer <token>` を付けてSpring Bootへリクエスト。
7. **トークン検証**: Spring BootがJWTの署名を検証。
