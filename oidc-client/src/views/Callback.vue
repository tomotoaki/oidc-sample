<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { handleCallback } from '@/services/oidcService'

const router = useRouter()

onMounted(async () => {
  try {
    await handleCallback()
    router.push('/profile')
  } catch (err) {
    console.error('Callback error', err)
    router.push('/')
  }
})
</script>

<template>
  <div class="callback">
    <p>Processing login...</p>
  </div>
</template>

<style scoped>
.callback {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  font-size: 1.2rem;
}
</style>
