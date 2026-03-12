<template>
  <div id="app">
    <header class="header">
      <div class="container">
        <div class="header-content">
          <div class="logo">🛡️ OIDC Sample</div>
          <nav class="nav">
            <router-link to="/" class="nav-link" :class="{ active: $route.path === '/' }">
              ホーム
            </router-link>
            <router-link 
              v-if="isAuthenticated" 
              to="/dashboard" 
              class="nav-link" 
              :class="{ active: $route.path === '/dashboard' }"
            >
              ダッシュボード
            </router-link>
            <span v-if="isAuthenticated" class="badge badge-success">
              認証済み
            </span>
          </nav>
        </div>
      </div>
    </header>

    <main>
      <router-view />
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { getUser } from './services/oidcService';

const isAuthenticated = ref(false);

onMounted(async () => {
  try {
    const user = await getUser();
    isAuthenticated.value = !!user && !user.expired;
  } catch (error) {
    console.error('Failed to check authentication status:', error);
  }
});
</script>
