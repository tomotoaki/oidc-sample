<template>
  <div class="container">
    <div class="page">
      <div class="loading">
        <p>認証処理中...</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { handleCallback } from '../services/oidcService';

const router = useRouter();

onMounted(async () => {
  try {
    await handleCallback();
    router.push('/dashboard');
  } catch (error) {
    console.error('Callback error:', error);
    alert('認証に失敗しました');
    router.push('/');
  }
});
</script>
