# 🚀 OIDC Sample - セットアップガイド

このガイドでは、OIDC認証のサンプルアプリケーション全体をセットアップする手順を説明します。

## 📋 前提条件

- Node.js (v18以上)
- Java 21以上 (Spring Boot 4.x用)
- Docker (Keycloak用、またはローカルインストール)

## 🏗️ アーキテクチャ概要

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   Frontend      │         │   Keycloak      │         │   Backend       │
│   (Vue.js)      │◄───────►│   (Auth)        │◄───────►│   (Spring Boot) │
│   Port: 8081    │         │   Port: 8082    │         │   Port: 8080    │
└─────────────────┘         └─────────────────┘         └─────────────────┘
```

## 1️⃣ Keycloakのセットアップ

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

### Keycloak管理コンソールにアクセス

1. ブラウザで `http://localhost:8082` を開く
2. ユーザー名: `admin`, パスワード: `admin` でログイン

### Realmの作成

1. 左上の「Master」をクリック → 「Create Realm」
2. Realm名: `myrealm` (任意)
3. 「Create」をクリック

### Clientの作成

1. 左メニューから「Clients」→「Create client」
2. 以下の設定を入力:

**General Settings:**
- Client type: `OpenID Connect`
- Client ID: `oidc-client`

**Capability config:**
- Client authentication: `ON` (Confidentialクライアント)
- Authorization: `OFF`
- Authentication flow:
  - ✅ Standard flow
  - ✅ Direct access grants
  - ❌ Implicit flow

**Login settings:**
- Valid redirect URIs: `http://localhost:8081/*`
- Valid post logout redirect URIs: `http://localhost:8081/`
- Web origins: `http://localhost:8081`

3. 「Save」をクリック

### Client Secretの取得

1. 「Credentials」タブをクリック
2. 「Client Secret」をコピーし、`src/services/oidcService.ts` の `client_secret` に設定してください。

### PKCE設定 (重要!)

1. 作成したクライアント (`oidc-client`) を開く
2. 「Advanced」タブをクリック
3. 「Proof Key for Code Exchange Code Challenge Method」を `S256` に設定
4. 「Save」をクリック

### テストユーザーの作成

1. 左メニューから「Users」→「Add user」
2. Username: `testuser`
3. 「Create」をクリック
4. 「Credentials」タブ → 「Set password」
5. Password: `password` (任意)
6. Temporary: `OFF`
7. 「Save」をクリック

## 2️⃣ Frontendのセットアップ

### 依存関係のインストール

```bash
cd oidc-client
npm install
```

### OIDC設定の確認

`src/services/oidcService.ts` を開き、`authority` が正しいか確認:

```typescript
authority: "http://localhost:8082/realms/myrealm", // realm名を確認
```

### 開発サーバーの起動

```bash
npm run dev
```

アプリケーションは `http://localhost:8081` で起動します。

## 3️⃣ Backend (Spring Boot) のセットアップ

### プロジェクトの作成

Spring Initializr (`https://start.spring.io/`) で以下の設定でプロジェクトを作成:

- Project: Gradle Project
- Language: Java
- Spring Boot: 3.2.x
- Dependencies:
  - Spring Web
  - OAuth2 Resource Server
  - Spring Security

### build.gradle

```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-oauth2-resource-server'
    implementation 'org.springframework.boot:spring-boot-starter-security'
}
```

### application.yml

```yaml
server:
  port: 8080

spring:
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8082/realms/myrealm
```

### SecurityConfig.java

```java
package com.example.oidc;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.config.Customizer;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .cors(Customizer.withDefaults())
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/public/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth -> oauth.jwt(Customizer.withDefaults()));
        return http.build();
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("http://localhost:8081"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

### UserController.java

```java
package com.example.oidc;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class UserController {
    
    @GetMapping("/user")
    public Map<String, Object> getUser(@AuthenticationPrincipal Jwt jwt) {
        Map<String, Object> response = new HashMap<>();
        response.put("username", jwt.getClaim("preferred_username"));
        response.put("email", jwt.getClaim("email"));
        response.put("subject", jwt.getSubject());
        response.put("message", "認証成功！バックエンドAPIにアクセスできました。");
        return response;
    }
    
    @GetMapping("/public/health")
    public Map<String, String> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "OK");
        response.put("message", "Backend is running");
        return response;
    }
}
```

### アプリケーションの起動

```bash
./gradlew bootRun
```

## 4️⃣ 動作確認

### 1. すべてのサービスが起動していることを確認

- Keycloak: `http://localhost:8082`
- Frontend: `http://localhost:8081`
- Backend: `http://localhost:8080`

### 2. フロントエンドでログイン

1. `http://localhost:8081` にアクセス
2. 「Keycloakでログイン」ボタンをクリック
3. Keycloakのログイン画面が表示される
4. Username: `user`, Password: `password` でログイン
5. ダッシュボードにリダイレクトされる

### 3. バックエンドAPIのテスト

1. ダッシュボードで「バックエンドAPIをテスト」ボタンをクリック
2. 成功すると、APIレスポンスが表示される

## 🔍 トラブルシューティング

### Keycloakに接続できない

- Dockerコンテナが起動しているか確認: `docker ps`
- ポート8082が使用されているか確認: `netstat -an | grep 8082`

### CORS エラー

- Keycloakの「Web origins」設定を確認
- Backendの`CorsConfiguration`を確認

### トークン検証エラー

- `application.yml`の`issuer-uri`が正しいか確認
- Keycloakのrealm名が一致しているか確認

### PKCE エラー

- Keycloakクライアントの「Advanced」タブで「PKCE Challenge Method」が`S256`に設定されているか確認

## 📚 参考資料

- [OpenID Connect Specification](https://openid.net/specs/openid-connect-core-1_0.html)
- [PKCE (RFC 7636)](https://tools.ietf.org/html/rfc7636)
- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [oidc-client-ts](https://github.com/authts/oidc-client-ts)

## 🎉 完了!

これで、PKCE対応のOIDC認証フローが動作するサンプルアプリケーションが完成しました！
