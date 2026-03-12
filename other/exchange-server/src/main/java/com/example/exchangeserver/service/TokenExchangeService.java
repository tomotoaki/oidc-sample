package com.example.exchangeserver.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.util.Map;

/**
 * Token Exchange サービス
 * Keycloakのtoken exchange APIを使用してトークンを交換する
 */
@Service
public class TokenExchangeService {

    private static final Logger log = LoggerFactory.getLogger(TokenExchangeService.class);

    private final WebClient webClient;

    @Value("${token-exchange.keycloak.token-endpoint}")
    private String tokenEndpoint;

    @Value("${token-exchange.keycloak.client-id}")
    private String clientId;

    @Value("${token-exchange.keycloak.client-secret}")
    private String clientSecret;

    // Standard Token Exchangeではaudienceパラメータは不要
    // @Value("${token-exchange.keycloak.audience}")
    // private String audience;

    public TokenExchangeService(WebClient webClient) {
        this.webClient = webClient;
    }

    /**
     * Token Exchangeを実行
     *
     * @param subjectToken 交換元のトークン
     * @return 交換後のトークン情報
     */
    public Map<String, Object> exchangeToken(String subjectToken) {
        log.info("Token Exchange開始: clientId={}", clientId);

        // Standard Token Exchange: 最小構成
        MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
        formData.add("grant_type", "urn:ietf:params:oauth:grant-type:token-exchange");
        formData.add("client_id", clientId);
        formData.add("client_secret", clientSecret);
        formData.add("subject_token", subjectToken);
        formData.add("subject_token_type", "urn:ietf:params:oauth:token-type:access_token");

        log.info("Token Exchange request parameters:");
        log.info("  - grant_type: urn:ietf:params:oauth:grant-type:token-exchange");
        log.info("  - client_id: {}", clientId);
        log.info("  - subject_token length: {}", subjectToken.length());
        log.info("  - endpoint: {}", tokenEndpoint);

        try {
            Map<String, Object> response = webClient.post()
                .uri(tokenEndpoint)
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(BodyInserters.fromFormData(formData))
                .retrieve()
                .bodyToMono(Map.class)
                .block();

            log.info("Token Exchange成功");
            log.info("Response: {}", response);
            return response;
        } catch (WebClientResponseException e) {
            log.error("Token Exchange失敗");
            log.error("Status: {}", e.getStatusCode());
            log.error("Response: {}", e.getResponseBodyAsString());
            log.error("Request - endpoint: {}, client_id: {}", tokenEndpoint, clientId);
            throw new RuntimeException("Token exchange failed: " + e.getStatusCode() + " - " + e.getResponseBodyAsString(), e);
        } catch (Exception e) {
            log.error("Token Exchange失敗（予期しないエラー）: {}", e.getMessage(), e);
            throw new RuntimeException("Token exchange failed unexpectedly", e);
        }
    }
}
