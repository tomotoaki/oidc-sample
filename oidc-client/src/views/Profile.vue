<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getUser, logout } from '@/services/oidcService'
import type { User } from 'oidc-client-ts'

const user = ref<User | null>(null)

onMounted(async () => {
  try {
    const loadedUser = await getUser()
    user.value = loadedUser
  } catch (err) {
    console.error('Failed to load user', err)
  }
})

const handleLogout = () => {
  logout()
}
</script>

<template>
  <div class="profile" v-if="user">
    <h1>User Profile</h1>
    <div class="info">
      <p><strong>Name:</strong> {{ user.profile.name }}</p>
      <p><strong>Email:</strong> {{ user.profile.email }}</p>
      <p><strong>Subject (ID):</strong> {{ user.profile.sub }}</p>
      <pre>{{ JSON.stringify(user.profile, null, 2) }}</pre>
    </div>
    <button @click="handleLogout">Logout</button>
  </div>
  <div v-else>
    <p>Loading user profile...</p>
  </div>
</template>

<style scoped>
.profile {
  padding: 20px;
  max-width: 600px;
  margin: 0 auto;
}

.info {
  margin-bottom: 20px;
  background-color: #f5f5f5;
  padding: 15px;
  border-radius: 5px;
  color: #333;
}

button {
  padding: 10px 20px;
  background-color: #d9534f;
  color: white;
  border: none;
  cursor: pointer;
  border-radius: 5px;
}

button:hover {
  background-color: #c9302c;
}
</style>
