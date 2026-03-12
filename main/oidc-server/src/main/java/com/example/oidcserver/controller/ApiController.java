package com.example.oidcserver.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class ApiController {

    /**
     * 公開エンドポイント - 認証不要
     */
    @GetMapping("/api/public/hello")
    public Map<String, String> publicHello() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Hello from public API!");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return response;
    }

    /**
     * 保護されたエンドポイント - 認証必要
     */
    @GetMapping("/api/protected/user")
    public Map<String, Object> protectedUser(@AuthenticationPrincipal Jwt jwt) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Hello from protected API!");
        response.put("username", jwt.getClaimAsString("preferred_username"));
        response.put("email", jwt.getClaimAsString("email"));
        response.put("subject", jwt.getSubject());
        response.put("claims", jwt.getClaims());
        return response;
    }

    /**
     * 保護されたエンドポイント - ダッシュボード用データ
     */
    @GetMapping("/api/protected/dashboard")
    public Map<String, Object> dashboard(@AuthenticationPrincipal Jwt jwt) {
        Map<String, Object> response = new HashMap<>();
        response.put("user", jwt.getClaimAsString("preferred_username"));
        response.put("data", Map.of(
            "tasks", 5,
            "messages", 12,
            "notifications", 3
        ));
        return response;
    }
}
