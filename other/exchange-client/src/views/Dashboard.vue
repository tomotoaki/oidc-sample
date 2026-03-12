<template>
  <div class="container">
    <div class="page">
      <h1 class="page-title">Exchange Client Dashboard</h1>
      <p class="page-subtitle">Token Exchange デモ（Main → Other）</p>

      <!-- Main Domainトークン情報 -->
      <div class="info-card">
        <h3>📝 Main Domainから受け取ったトークン</h3>
        <div v-if="mainToken" class="token-display">
          {{ mainToken.substring(0, 50) }}...
        </div>
        <div v-else class="alert alert-warning">
          Main Domainからトークンが渡されていません。<br>
          <a href="http://localhost:8081/dashboard" class="btn btn-link">Main Domainに戻る</a>
        </div>
      </div>

      <!-- Token Exchange -->
      <div class="info-card">
        <h3>🔄 Token Exchange</h3>
        <p style="margin-bottom: 1rem;">
          Main DomainのトークンをOther Domain（exchange-server）で使用できるトークンに交換します
        </p>
        <button
          @click="executeTokenExchange"
          class="btn btn-primary"
          :disabled="exchanging || !mainToken"
        >
          {{ exchanging ? '交換中...' : 'トークン交換を実行' }}
        </button>

        <div v-if="exchangedToken" class="alert alert-success" style="margin-top: 1rem;">
          <h4>✅ Token Exchange 成功</h4>
          <div class="token-display" style="margin-top: 0.5rem;">
            {{ exchangedToken.substring(0, 50) }}...
          </div>
        </div>

        <div v-if="exchangeError" class="alert alert-error" style="margin-top: 1rem;">
          <strong>❌ エラー:</strong> {{ exchangeError }}
        </div>
      </div>

      <!-- Exchange Server保護されたAPI呼び出し -->
      <div class="info-card">
        <h3>🔒 Exchange Server 保護されたAPI呼び出し</h3>
        <p style="margin-bottom: 1rem;">
          交換されたトークンを使ってExchange Server (127.0.0.1:8090) の保護されたAPIを呼び出します
        </p>
        <button
          @click="callProtectedInfo"
          class="btn btn-secondary"
          :disabled="calling || !exchangedToken"
        >
          {{ calling ? '呼び出し中...' : 'Protected APIを呼び出す' }}
        </button>

        <div v-if="protectedApiResponse" class="alert alert-success" style="margin-top: 1rem;">
          <h4>✅ API呼び出し成功</h4>
          <pre>{{ JSON.stringify(protectedApiResponse, null, 2) }}</pre>
        </div>

        <div v-if="apiError" class="alert alert-error" style="margin-top: 1rem;">
          <strong>❌ エラー:</strong> {{ apiError }}
        </div>
      </div>

      <div class="btn-group">
        <a href="http://localhost:8081/dashboard" class="btn btn-secondary">
          Main Domainに戻る
        </a>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { exchangeToken, callProtectedApi } from '../services/apiService';

const route = useRoute();
const mainToken = ref<string | null>(null);
const exchangedToken = ref<string | null>(null);
const exchangeError = ref<string | null>(null);
const exchanging = ref(false);
const protectedApiResponse = ref<any>(null);
const apiError = ref<string | null>(null);
const calling = ref(false);

onMounted(async () => {
  // URLパラメータからトークンを取得（シンプルな実装）
  const token = route.query.token as string;
  if (token) {
    mainToken.value = token;
  }
});

const executeTokenExchange = async () => {
  exchanging.value = true;
  exchangeError.value = null;
  exchangedToken.value = null;

  try {
    const result = await exchangeToken(mainToken.value!);
    exchangedToken.value = result.access_token;
  } catch (error: any) {
    console.error('Token exchange error:', error);
    exchangeError.value = error.message || 'トークン交換に失敗しました';
  } finally {
    exchanging.value = false;
  }
};

const callProtectedInfo = async () => {
  calling.value = true;
  apiError.value = null;
  protectedApiResponse.value = null;

  try {
    const result = await callProtectedApi(exchangedToken.value!);
    protectedApiResponse.value = result;
  } catch (error: any) {
    console.error('Protected API call error:', error);
    apiError.value = error.message || 'API呼び出しに失敗しました';
  } finally {
    calling.value = false;
  }
};
</script>
