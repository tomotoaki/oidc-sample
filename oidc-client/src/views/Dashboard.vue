<template>
  <div class="page">
    <div class="container">
      <div v-if="loading" class="loading-container">
        <div class="spinner"></div>
        <p>ユーザー情報を読み込み中...</p>
      </div>

      <div v-else-if="user" style="max-width: 800px; margin: 0 auto; width: 100%;">
        <div class="card card-elevated">
          <h1 class="text-center">👤 Dashboard</h1>

          <div class="user-info">
            <div class="user-avatar">
              {{ getInitials(user.profile.name) }}
            </div>
            <div class="user-details">
              <h3>{{ user.profile.name || 'User' }}</h3>
              <p>{{ user.profile.email || 'No email' }}</p>
              <span class="badge">認証済み</span>
            </div>
          </div>

          <h3>📊 User Details</h3>
          <div class="info-grid">
            <div class="info-item">
              <h4>Username</h4>
              <p>{{ user.profile.preferred_username || 'N/A' }}</p>
            </div>
            <div class="info-item">
              <h4>Email</h4>
              <p>{{ user.profile.email || 'N/A' }}</p>
            </div>
            <div class="info-item">
              <h4>Expiry</h4>
              <p>{{ formatExpiry(user.expires_at) }}</p>
            </div>
          </div>

          <div style="margin: var(--spacing-lg) 0; padding: var(--spacing-md); background: var(--color-surface-variant); border-radius: var(--radius-md);">
            <h3>🔑 Access Token</h3>
            <code style="word-break: break-all; opacity: 0.7;">
              {{ user.access_token.substring(0, 50) }}...
            </code>
          </div>

          <div class="flex gap-md mt-lg justify-center">
            <button @click="testApi" class="btn btn-primary" :disabled="apiLoading">
              🚀 API Test
            </button>
            <button @click="handleGetUserInfo" class="btn btn-secondary" :disabled="userInfoLoading">
              🔍 UserInfo
            </button>
            <button @click="handleLogout" class="btn btn-danger">
              🚪 Logout
            </button>
          </div>

          <div v-if="userInfoResponse" class="mt-lg">
            <h3>👤 UserInfo Response</h3>
            <pre>{{ userInfoResponse }}</pre>
          </div>

          <div v-if="apiResponse" class="mt-lg">
            <h3>📡 API Response</h3>
            <pre>{{ apiResponse }}</pre>
          </div>

          <div v-if="apiError || userInfoError" class="mt-lg" style="color: var(--color-error);">
            <h3>❌ Error</h3>
            <p>{{ apiError || userInfoError }}</p>
          </div>
        </div>
      </div>

      <div v-else class="card text-center" style="max-width: 400px; margin: 0 auto;">
        <h3>⚠️ Session Not Found</h3>
        <button @click="goHome" class="btn btn-primary mt-lg">
          Go Home
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { getUser, logout, getAccessToken, fetchUserInfo } from '../services/oidcService';
import type { User } from 'oidc-client-ts';

const router = useRouter();
const user = ref<User | null>(null);
const loading = ref(true);
const apiLoading = ref(false);
const apiResponse = ref<string | null>(null);
const apiError = ref<string | null>(null);

const userInfoLoading = ref(false);
const userInfoResponse = ref<string | null>(null);
const userInfoError = ref<string | null>(null);

onMounted(async () => {
  try {
    user.value = await getUser();
  } catch (error) {
    console.error('Failed to get user:', error);
  } finally {
    loading.value = false;
  }
});

const getInitials = (name?: string): string => {
  if (!name) return '?';
  const parts = name.split(' ');
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name.substring(0, 2).toUpperCase();
};

const formatExpiry = (expiresAt?: number): string => {
  if (!expiresAt) return 'N/A';
  const date = new Date(expiresAt * 1000);
  return date.toLocaleString('ja-JP');
};

const handleLogout = async () => {
  try {
    await logout();
  } catch (error) {
    console.error('Logout failed:', error);
  }
};

const goHome = () => {
  router.push('/');
};

const testApi = async () => {
  apiLoading.value = true;
  apiResponse.value = null;
  apiError.value = null;

  try {
    const token = await getAccessToken();
    
    if (!token) {
      throw new Error('アクセストークンが見つかりません');
    }

    // バックエンドAPIを呼び出し (例: http://localhost:8080/api/user)
    const response = await fetch('http://localhost:8080/api/user', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();
    apiResponse.value = JSON.stringify(data, null, 2);
  } catch (error) {
    console.error('API call failed:', error);
    apiError.value = error instanceof Error ? error.message : 'APIの呼び出しに失敗しました';
  } finally {
    apiLoading.value = false;
  }
};

const handleGetUserInfo = async () => {
  userInfoLoading.value = true;
  userInfoResponse.value = null;
  userInfoError.value = null;

  try {
    const data = await fetchUserInfo();
    userInfoResponse.value = JSON.stringify(data, null, 2);
  } catch (error) {
    console.error('UserInfo fetch failed:', error);
    userInfoError.value = error instanceof Error ? error.message : 'UserInfoの取得に失敗しました';
  } finally {
    userInfoLoading.value = false;
  }
};
</script>
