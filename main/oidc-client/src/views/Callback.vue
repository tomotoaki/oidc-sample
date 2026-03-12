<template>
  <div class="page">
    <div class="container">
      <div v-if="loading" class="loading-container">
        <div class="spinner"></div>
        <p>認証情報を処理中...</p>
      </div>

      <div v-else-if="error" class="card card-glass text-center" style="max-width: 600px; margin: 0 auto;">
        <h2>❌ 認証エラー</h2>
        <p style="color: var(--color-error); font-size: var(--font-size-lg);">
          {{ error }}
        </p>
        <button @click="goHome" class="btn btn-primary mt-lg">
          ホームに戻る
        </button>
      </div>

      <div v-else class="card card-glass text-center" style="max-width: 600px; margin: 0 auto;">
        <h2>✅ 認証成功</h2>
        <p style="font-size: var(--font-size-lg); color: var(--color-success);">
          リダイレクト中...
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { handleCallback } from '../services/oidcService';

const router = useRouter();
const loading = ref(true);
const error = ref<string | null>(null);

onMounted(async () => {
  try {
    // OIDC コールバック処理 (state, nonce, PKCE の自動検証)
    await handleCallback();
    
    // 成功したらダッシュボードへリダイレクト
    setTimeout(() => {
      router.push('/dashboard');
    }, 1000);
  } catch (err) {
    console.error('Callback error:', err);
    error.value = err instanceof Error ? err.message : '認証処理中にエラーが発生しました';
    loading.value = false;
  }
});

const goHome = () => {
  router.push('/');
};
</script>
