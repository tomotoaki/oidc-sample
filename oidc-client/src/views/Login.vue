<script setup lang="ts">
import { login } from '@/services/oidcService'

const handleLogin = () => {
  login().catch((err) => console.error('Login failed', err))
}
</script>

<template>
  <div class="login-container">
    <h1>Welcome to OIDC Sample</h1>
    <p>Please log in to continue.</p>
    <button @click="handleLogin">Login with Keycloak</button>
  </div>
</template>

<style scoped>
.login-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
}

button {
  padding: 10px 20px;
  font-size: 16px;
  cursor: pointer;
}
</style>
