<template>
  <div class="page">
    <div class="container">
      <div class="card card-elevated text-center" style="max-width: 600px; margin: 0 auto;">
        <h1>🛡️ OIDC Sample</h1>
        <p>
          OpenID Connect (OIDC) 認証のデモアプリケーション
        </p>
        
        <div class="info-grid text-center" style="margin: var(--spacing-xl) 0;">
          <div class="info-item">
            <h4>Security</h4>
            <p>PKCE対応</p>
          </div>
          <div class="info-item">
            <h4>Flow</h4>
            <p>Auth Code</p>
          </div>
          <div class="info-item">
            <h4>Provider</h4>
            <p>Keycloak</p>
          </div>
        </div>

        <div class="flex flex-column gap-md items-center">
          <button @click="handleLogin" class="btn btn-primary">
            🔑 Keycloakでログイン
          </button>
          <p style="font-size: 0.875rem;">
            ログインを行うと認証画面へリダイレクトします
          </p>
        </div>
      </div>

      <div class="card" style="max-width: 600px; margin: 0 auto;">
        <h3>📋 機能一覧</h3>
        <ul style="text-align: left; list-style: none; padding: var(--spacing-md) 0;">
          <li style="margin-bottom: var(--spacing-sm);">🛡️ <strong>PKCE</strong>: 認可コード横取りの防止</li>
          <li style="margin-bottom: var(--spacing-sm);">🔐 <strong>State/Nonce</strong>: CSRF・リプレイ攻撃の防止</li>
          <li style="margin-bottom: var(--spacing-sm);">🔑 <strong>JWT</strong>: バックエンドでのアクセス検証</li>
        </ul>
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
    console.error('Login failed:', error);
    alert('ログインに失敗しました。Keycloakが起動しているか確認してください。');
  }
};
</script>
