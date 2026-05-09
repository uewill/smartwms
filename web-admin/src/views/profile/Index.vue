<template>
  <div class="profile">
    <a-row :gutter="16">
      <a-col :span="16">
        <a-card title="个人信息">
          <a-form :model="form" layout="vertical">
            <a-form-item label="姓名">
              <a-input v-model="form.name" />
            </a-form-item>
            <a-form-item label="手机号">
              <a-input v-model="form.phone" disabled />
            </a-form-item>
            <a-form-item label="邮箱">
              <a-input v-model="form.email" />
            </a-form-item>
            <a-form-item label="级别">
              <a-tag :color="levelColors[form.level]">{{ levelText[form.level] }}</a-tag>
            </a-form-item>
            <a-form-item>
              <a-button type="primary" @click="handleSave">保存修改</a-button>
            </a-form-item>
          </a-form>
        </a-card>

        <a-card title="修改密码" style="margin-top: 16px">
          <a-form :model="pwdForm" layout="vertical">
            <a-form-item label="原密码">
              <a-input-password v-model="pwdForm.oldPassword" />
            </a-form-item>
            <a-form-item label="新密码">
              <a-input-password v-model="pwdForm.newPassword" />
            </a-form-item>
            <a-form-item label="确认密码">
              <a-input-password v-model="pwdForm.confirmPassword" />
            </a-form-item>
            <a-form-item>
              <a-button type="primary" @click="handleChangePwd">修改密码</a-button>
            </a-form-item>
          </a-form>
        </a-card>
      </a-col>

      <a-col :span="8">
        <a-card title="账号信息">
          <a-descriptions :column="1">
            <a-descriptions-item label="租户">{{ authStore.tenant?.name }}</a-descriptions-item>
            <a-descriptions-item label="用户">{{ authStore.user?.nickname }}</a-descriptions-item>
            <a-descriptions-item label="手机号">{{ authStore.user?.phone }}</a-descriptions-item>
            <a-descriptions-item label="微信">
              <a-tag v-if="authStore.user?.wechatOpenId" color="green">已绑定</a-tag>
              <a-tag v-else color="default">未绑定</a-tag>
            </a-descriptions-item>
          </a-descriptions>
        </a-card>

        <a-card title="操作日志" style="margin-top: 16px">
          <a-list :data="logs" :bordered="false" size="small">
            <template #item="{ item }">
              <a-list-item>
                <a-list-item-meta :title="item.action" :description="item.detail" />
              </a-list-item>
            </template>
          </a-list>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useAuthStore } from '../../store/auth'
import { authApi } from '../../api'
import { Message } from '@arco-design/web-vue'

const authStore = useAuthStore()
const logs = ref([])

const form = reactive({
  name: '',
  phone: '',
  email: '',
  level: 3
})

const pwdForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const levelText = { 1: '超级管理员', 2: '管理员', 3: '操作员', 4: '查看者' }
const levelColors = { 1: 'red', 2: 'blue', 3: 'green', 4: 'orange' }

onMounted(async () => {
  if (authStore.staff) {
    form.name = authStore.staff.name
    form.phone = authStore.staff.phone
    form.email = authStore.staff.email || ''
    form.level = authStore.staff.level
  }

  try {
    const res = await authApi.getOperationLogs()
    if (res.code === 0) {
      logs.value = (res.data || []).slice(0, 10)
    }
  } catch (e) {
    console.error(e)
  }
})

const handleSave = async () => {
  Message.success('保存成功')
}

const handleChangePwd = async () => {
  if (pwdForm.newPassword !== pwdForm.confirmPassword) {
    Message.error('两次密码输入不一致')
    return
  }
  try {
    await authApi.changePassword(pwdForm.oldPassword, pwdForm.newPassword)
    Message.success('密码修改成功')
    pwdForm.oldPassword = ''
    pwdForm.newPassword = ''
    pwdForm.confirmPassword = ''
  } catch (e) {
    Message.error('修改失败')
  }
}
</script>
