<template>
  <div class="login-container">
    <div class="login-box">
      <div class="login-header">
        <h1>SmartWMS</h1>
        <p>智能仓储管理系统</p>
      </div>

      <a-tabs v-model:activeKey="loginType" size="large" class="login-tabs">
        <a-tab-pane key="password" tab="密码登录" />
        <a-tab-pane key="code" tab="验证码登录" />
      </a-tabs>

      <a-form :model="form" layout="vertical" @submit="handleLogin">
        <a-form-item label="手机号">
          <a-input v-model="form.phone" placeholder="请输入手机号" size="large" />
        </a-form-item>

        <a-form-item v-if="loginType === 'password'" label="密码">
          <a-input-password v-model="form.password" placeholder="请输入密码" size="large" />
        </a-form-item>

        <a-form-item v-else label="验证码">
          <div class="code-input">
            <a-input v-model="form.code" placeholder="请输入验证码" size="large" />
            <a-button :disabled="countdown > 0" @click="sendCode">
              {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
            </a-button>
          </div>
        </a-form-item>

        <a-form-item>
          <a-button type="primary" html-type="submit" long size="large" :loading="loading">
            登录
          </a-button>
        </a-form-item>
      </a-form>

      <div class="login-footer">
        <span>还没有账号？</span>
        <router-link to="/register">立即注册</router-link>
      </div>

      <div class="wechat-login">
        <a-divider>其他登录方式</a-divider>
        <a-button type="outline" long @click="handleWechatLogin">
          <template #icon><span class="wechat-icon">W</span></template>
          微信登录
        </a-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../store/auth'
import { authApi } from '../../api'
import { Message } from '@arco-design/web-vue'

const router = useRouter()
const authStore = useAuthStore()

const loginType = ref('password')
const loading = ref(false)
const countdown = ref(0)

const form = reactive({
  phone: '',
  password: '',
  code: ''
})

const sendCode = async () => {
  if (!form.phone) {
    Message.warning('请输入手机号')
    return
  }
  try {
    await authApi.sendCode(form.phone, 'login')
    Message.success('验证码已发送')
    countdown.value = 60
    const timer = setInterval(() => {
      countdown.value--
      if (countdown.value <= 0) clearInterval(timer)
    }, 1000)
  } catch (e) {
    Message.error('发送失败')
  }
}

const handleLogin = async () => {
  if (!form.phone) {
    Message.warning('请输入手机号')
    return
  }

  loading.value = true
  try {
    let success
    if (loginType.value === 'password') {
      if (!form.password) {
        Message.warning('请输入密码')
        loading.value = false
        return
      }
      success = await authStore.loginByPassword(form.phone, form.password)
    } else {
      if (!form.code) {
        Message.warning('请输入验证码')
        loading.value = false
        return
      }
      success = await authStore.loginByCode(form.phone, form.code)
    }

    if (success) {
      Message.success('登录成功')
      router.push('/dashboard')
    } else {
      Message.error('登录失败')
    }
  } catch (e) {
    Message.error('登录失败')
  } finally {
    loading.value = false
  }
}

const handleWechatLogin = () => {
  Message.info('微信登录功能开发中')
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #165dff 0%, #4080ff 100%);
}

.login-box {
  width: 400px;
  padding: 40px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
}

.login-header {
  text-align: center;
  margin-bottom: 30px;
}

.login-header h1 {
  font-size: 28px;
  color: #165dff;
  margin-bottom: 8px;
}

.login-header p {
  color: #86909c;
  font-size: 14px;
}

.login-tabs {
  margin-bottom: 24px;
}

.code-input {
  display: flex;
  gap: 12px;
}

.code-input .arco-input-wrapper {
  flex: 1;
}

.login-footer {
  text-align: center;
  margin-top: 16px;
  color: #86909c;
}

.login-footer a {
  color: #165dff;
  margin-left: 4px;
}

.wechat-login {
  margin-top: 24px;
}

.wechat-icon {
  display: inline-block;
  width: 18px;
  height: 18px;
  background: #07c160;
  color: #fff;
  border-radius: 50%;
  text-align: center;
  line-height: 18px;
  font-size: 12px;
  font-weight: bold;
}
</style>
