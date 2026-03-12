package com.example.exchangeserver.controller;

import com.example.exchangeserver.service.TokenExchangeService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class TokenExchangeController {

    private static final Logger log = LoggerFactory.getLogger(TokenExchangeController.class);

    private final TokenExchangeService tokenExchangeService;

    public TokenExchangeController(TokenExchangeService tokenExchangeService) {
        this.tokenExchangeService = tokenExchangeService;
    }

    /**
     * 公開エンドポイント - 認証不要
     */
    @GetMapping("/public")
    public Map<String, String> publicEndpoint() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Hello from Exchange Server (Other Domain)!");
        response.put("domain", "127.0.0.1:8090");
        response.put("timestamp", String.valueOf(System.currentTimeMillis()));
        return response;
    }

    /**
     * Token Exchange実行エンドポイント
     * mainでログイン取得したトークン（Token A）を、exchange-server用のトークン（Token B）に交換する
     */
    @PostMapping("/exchange")
    public ResponseEntity<?> exchangeToken(@RequestBody Map<String, String> request) {
        try {
            String subjectToken = request.get("token");

            if (subjectToken == null || subjectToken.isEmpty()) {
                Map<String, String> error = new HashMap<>();
                error.put("status", "error");
                error.put("message", "Token is required");
                return ResponseEntity.badRequest().body(error);
            }

            log.info("Token Exchange リクエスト受信");

            Map<String, Object> exchangedToken = tokenExchangeService.exchangeToken(subjectToken);

            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Token exchanged successfully");
            response.put("access_token", exchangedToken.get("access_token"));

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Token Exchange エラー", e);
            Map<String, String> error = new HashMap<>();
            error.put("status", "error");
            error.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Exchange Serverの保護されたエンドポイント（動作確認用）
     */
    @GetMapping("/protected/info")
    public Map<String, Object> protectedInfo(@AuthenticationPrincipal Jwt jwt) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "This is Exchange Server protected endpoint");
        response.put("user", jwt.getClaimAsString("preferred_username"));
        response.put("email", jwt.getClaimAsString("email"));
        response.put("domain", "127.0.0.1:8090");
        return response;
    }
}
