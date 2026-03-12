<template>
  <div class="container">
    <div class="page">
      <h1 class="page-title">Token Exchange Client</h1>
      <p class="page-subtitle">
        Cross-Domain Token Exchange のデモアプリケーション<br>
        Domain: 127.0.0.1:8091 (Other Domain)
      </p>

      <div class="alert alert-info">
        <strong>🔄 Token Exchange フロー:</strong><br>
        1. このクライアント（Other Domain）でKeycloak認証<br>
        2. 取得したトークンをExchange Serverに送信<br>
        3. Main DomainのOIDC Serverにアクセス可能なトークンに交換<br>
        4. 交換したトークンでMain DomainのAPIを呼び出し
      </div>

      <div class="info-card">
        <h3>システム構成</h3>
        <div class="info-row">
          <div class="info-label">Exchange Client:</div>
          <div class="info-value">http://127.0.0.1:8091 (Other Domain)</div>
        </div>
        <div class="info-row">
          <div class="info-label">Exchange Server:</div>
          <div class="info-value">http://127.0.0.1:8090 (Other Domain)</div>
        </div>
        <div class="info-row">
          <div class="info-label">OIDC Server:</div>
          <div class="info-value">http://localhost:8080 (Main Domain)</div>
        </div>
        <div class="info-row">
          <div class="info-label">Keycloak IDP:</div>
          <div class="info-value">http://localhost:8082</div>
        </div>
      </div>

      <div class="btn-group">
        <button @click="handleLogin" class="btn btn-primary">
          🔐 Keycloakでログイン
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { login } from '../services/oidcService';

const handleLogin = async () => {
  try {
    await login();
  } catch (error) {
    console.error('Login error:', error);
    alert('ログインに失敗しました');
  }
};
</script>
