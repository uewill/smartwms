<template>
  <div class="login-container">
    <div class="login-box">
      <div class="login-header">
        <h1>SmartWMS</h1>
        <p>创建您的仓储管理系统</p>
      </div>

      <a-form :model="form" layout="vertical" @submit="handleRegister">
        <a-form-item label="企业名称" required>
          <a-input v-model="form.name" placeholder="请输入企业/组织名称" size="large" />
        </a-form-item>

        <a-form-item label="管理员姓名" required>
          <a-input v-model="form.adminName" placeholder="请输入管理员姓名" size="large" />
        </a-form-item>

        <a-form-item label="手机号" required>
          <a-input v-model="form.phone" placeholder="请输入手机号" size="large" />
        </a-form-item>

        <a-form-item label="设置密码" required>
          <a-input-password v-model="form.password" placeholder="请设置登录密码（至少6位）" size="large" />
        </a-form-item>

        <a-form-item label="验证码" required>
          <div class="code-input">
            <a-input v-model="form.code" placeholder="请输入验证码" size="large" />
            <a-button :disabled="countdown > 0" @click="sendCode">
              {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
            </a-button>
          </div>
        </a-form-item>

        <a-form-item>
          <a-checkbox v-model="agreed">
            我已阅读并同意 <a-link>《服务协议》</a-link> 和 <a-link>《隐私政策》</a-link>
          </a-checkbox>
        </a-form-item>

        <a-form-item>
          <a-button type="primary" html-type="submit" long size="large" :loading="loading" :disabled="!agreed">
            注册
          </a-button>
        </a-form-item>
      </a-form>

      <div class="login-footer">
        <span>已有账号？</span>
        <router-link to="/login">立即登录</router-link>
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

const loading = ref(false)
const countdown = ref(0)
const agreed = ref(false)

const form = reactive({
  name: '',
  adminName: '',
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
    await authApi.sendCode(form.phone, 'register')
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

const handleRegister = async () => {
  if (!form.name || !form.adminName || !form.phone || !form.password) {
    Message.warning('请填写完整信息')
    return
  }
  if (form.password.length < 6) {
    Message.warning('密码至少6位')
    return
  }
  if (!form.code) {
    Message.warning('请输入验证码')
    return
  }

  loading.value = true
  try {
    const success = await authStore.register({
      phone: form.phone,
      password: form.password,
      name: form.adminName
    })

    if (success) {
      Message.success('注册成功')
      router.push('/dashboard')
    } else {
      Message.error('注册失败')
    }
  } catch (e) {
    Message.error('注册失败')
  } finally {
    loading.value = false
  }
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
  width: 420px;
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
</style>
