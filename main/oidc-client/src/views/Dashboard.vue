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
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: var(--spacing-sm);">
              <h3>🔑 Access Token</h3>
              <div style="display: flex; gap: var(--spacing-sm);">
                <button @click="copyToken" class="btn btn-secondary" style="padding: 4px 12px; font-size: 0.9rem;">
                  {{ tokenCopied ? '✓ コピー済み' : '📋 コピー' }}
                </button>
                <button @click="toggleTokenDisplay" class="btn btn-secondary" style="padding: 4px 12px; font-size: 0.9rem;">
                  {{ showFullToken ? '▲ 折りたたむ' : '▼ 全文表示' }}
                </button>
              </div>
            </div>
            <code :style="{ wordBreak: 'break-all', opacity: '0.7', display: 'block', maxHeight: showFullToken ? 'none' : '100px', overflow: 'auto', background: 'rgba(0,0,0,0.1)', padding: 'var(--spacing-sm)', borderRadius: 'var(--radius-sm)' }">{{ showFullToken ? user.access_token : (user.access_token.substring(0, 100) + '...') }}</code>
            <p style="font-size: 0.85rem; margin-top: var(--spacing-sm); opacity: 0.7;">
              💡 トークンを <a href="https://jwt.io" target="_blank" style="color: var(--color-primary); text-decoration: underline;">jwt.io</a> で確認して、<code>aud</code>クレームに<code>exchange-server</code>が含まれているか確認してください
            </p>
          </div>

          <div class="flex gap-md mt-lg justify-center flex-wrap">
            <button @click="testPublicApi" class="btn btn-secondary" :disabled="apiLoading">
              🌐 Public API
            </button>
            <button @click="testProtectedUser" class="btn btn-primary" :disabled="apiLoading">
              👤 User API
            </button>
            <button @click="testProtectedDashboard" class="btn btn-primary" :disabled="apiLoading">
              📊 Dashboard API
            </button>
            <button @click="handleGetUserInfo" class="btn btn-secondary" :disabled="userInfoLoading">
              🔍 UserInfo
            </button>
            <button @click="handleLogout" class="btn btn-danger">
              🚪 Logout
            </button>
            <button @click="handleForceLogout" class="btn btn-danger" style="background: #d32f2f;">
              💥 強制ログアウト（キャッシュクリア）
            </button>
          </div>

          <!-- Token Exchange Section -->
          <div style="margin: var(--spacing-lg) 0; padding: var(--spacing-md); background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: var(--radius-md); text-align: center;">
            <h3 style="color: white; margin-bottom: var(--spacing-sm);">🔄 Cross-Domain Token Exchange</h3>
            <p style="color: rgba(255,255,255,0.9); margin-bottom: var(--spacing-md);">
              このトークンを使って、Other Domain (127.0.0.1:8091) にアクセスします
            </p>
            <button @click="goToOtherDomain" class="btn" style="background: white; color: #667eea; font-weight: 600;">
              🚀 Other Domainに移動（Token Exchange）
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
import { getUser, logout, forceLogout, fetchUserInfo } from '../services/oidcService';
import { getPublicHello, getProtectedUser, getProtectedDashboard } from '../services/apiService';
import type { User } from 'oidc-client-ts';

const router = useRouter();
const user = ref<User | null>(null);
const loading = ref(true);
const apiLoading = ref(false);
const apiResponse = ref<string | null>(null);
const apiError = ref<string | null>(null);

const showFullToken = ref(false);
const tokenCopied = ref(false);

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

const toggleTokenDisplay = () => {
  showFullToken.value = !showFullToken.value;
};

const copyToken = async () => {
  if (user.value && user.value.access_token) {
    try {
      await navigator.clipboard.writeText(user.value.access_token);
      tokenCopied.value = true;
      setTimeout(() => {
        tokenCopied.value = false;
      }, 2000);
    } catch (error) {
      console.error('Failed to copy token:', error);
      alert('トークンのコピーに失敗しました');
    }
  }
};

const handleLogout = async () => {
  try {
    await logout();
  } catch (error) {
    console.error('Logout failed:', error);
  }
};

const handleForceLogout = async () => {
  try {
    await forceLogout();
  } catch (error) {
    console.error('Force logout failed:', error);
  }
};

const goToOtherDomain = async () => {
  if (user.value && user.value.access_token) {
    try {
      console.log('Token Exchange開始...');

      // Token Exchangeを実行
      const response = await fetch('http://127.0.0.1:8090/api/exchange', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          token: user.value.access_token
        })
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('Token Exchange失敗:', response.status, errorText);
        alert(`Token Exchange失敗: ${response.status} - ${errorText}`);
        return;
      }

      const data = await response.json();
      console.log('Token Exchange成功:', data);

      // 交換後のトークンで Other Domain にリダイレクト
      const exchangedToken = data.access_token;
      window.location.href = `http://127.0.0.1:8091/dashboard?token=${encodeURIComponent(exchangedToken)}`;
    } catch (error) {
      console.error('Token Exchange エラー:', error);
      alert(`Token Exchange エラー: ${error.message}`);
    }
  }
};

const goHome = () => {
  router.push('/');
};

const testPublicApi = async () => {
  apiLoading.value = true;
  apiResponse.value = null;
  apiError.value = null;

  try {
    const data = await getPublicHello();
    apiResponse.value = JSON.stringify(data, null, 2);
  } catch (error) {
    console.error('Public API call failed:', error);
    apiError.value = error instanceof Error ? error.message : '公開APIの呼び出しに失敗しました';
  } finally {
    apiLoading.value = false;
  }
};

const testProtectedUser = async () => {
  apiLoading.value = true;
  apiResponse.value = null;
  apiError.value = null;

  try {
    const data = await getProtectedUser();
    apiResponse.value = JSON.stringify(data, null, 2);
  } catch (error) {
    console.error('Protected User API call failed:', error);
    apiError.value = error instanceof Error ? error.message : 'ユーザーAPIの呼び出しに失敗しました';
  } finally {
    apiLoading.value = false;
  }
};

const testProtectedDashboard = async () => {
  apiLoading.value = true;
  apiResponse.value = null;
  apiError.value = null;

  try {
    const data = await getProtectedDashboard();
    apiResponse.value = JSON.stringify(data, null, 2);
  } catch (error) {
    console.error('Protected Dashboard API call failed:', error);
    apiError.value = error instanceof Error ? error.message : 'ダッシュボードAPIの呼び出しに失敗しました';
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
