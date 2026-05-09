<template>
  <div class="staff">
    <a-card>
      <template #title>
        <div class="card-header">
          <span>职员管理</span>
          <a-button type="primary" @click="showForm = true">
            <template #icon><IconPlus /></template>
            新建职员
          </a-button>
        </div>
      </template>

      <a-table :columns="columns" :data="staffs" :loading="loading">
        <template #level="{ record }">
          <a-tag :color="levelColors[record.level]">{{ levelText[record.level] }}</a-tag>
        </template>
        <template #status="{ record }">
          <a-tag :color="record.status === 'active' ? 'green' : 'default'">
            {{ record.status === 'active' ? '启用' : '停用' }}
          </a-tag>
        </template>
        <template #actions="{ record }">
          <a-button type="text" size="small" @click="handleEdit(record)">编辑</a-button>
          <a-popconfirm content="确认删除？" @ok="handleDelete(record.id)">
            <a-button type="text" size="small" status="danger">删除</a-button>
          </a-popconfirm>
        </template>
      </a-table>
    </a-card>

    <a-modal v-model:visible="showForm" :title="editingId ? '编辑职员' : '新建职员'" @before-ok="handleSubmit" @cancel="resetForm">
      <a-form :model="form" layout="vertical">
        <a-form-item label="姓名" required>
          <a-input v-model="form.name" placeholder="请输入姓名" />
        </a-form-item>
        <a-form-item label="手机号" required>
          <a-input v-model="form.phone" placeholder="请输入手机号" />
        </a-form-item>
        <a-form-item label="邮箱">
          <a-input v-model="form.email" placeholder="请输入邮箱" />
        </a-form-item>
        <a-form-item label="职员级别" required>
          <a-radio-group v-model="form.level">
            <a-radio :value="1">超级管理员</a-radio>
            <a-radio :value="2">管理员</a-radio>
            <a-radio :value="3">操作员</a-radio>
            <a-radio :value="4">查看者</a-radio>
          </a-radio-group>
          <div class="level-desc">{{ levelDesc[form.level] }}</div>
        </a-form-item>
        <a-form-item label="备注">
          <a-textarea v-model="form.remark" placeholder="备注" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { staffApi } from '../../api'
import { IconPlus } from '@arco-design/web-vue/es/icon'

const loading = ref(false)
const staffs = ref([])
const showForm = ref(false)
const editingId = ref(null)

const form = reactive({
  name: '',
  phone: '',
  email: '',
  level: 3,
  remark: ''
})

const levelText = { 1: '超级管理员', 2: '管理员', 3: '操作员', 4: '查看者' }
const levelColors = { 1: 'red', 2: 'blue', 3: 'green', 4: 'orange' }
const levelDesc = {
  1: '拥有所有权限，可管理所有职员和系统设置',
  2: '管理仓库、商品、订单等业务数据',
  3: '执行入库、出库等操作',
  4: '仅可查看数据，无法进行操作'
}

const columns = [
  { title: '姓名', dataIndex: 'name' },
  { title: '手机号', dataIndex: 'phone', width: 130 },
  { title: '邮箱', dataIndex: 'email', width: 180 },
  { title: '级别', slotName: 'level', width: 100 },
  { title: '状态', slotName: 'status', width: 80 },
  { title: '创建时间', dataIndex: 'createdAt', width: 160 },
  { title: '操作', slotName: 'actions', width: 150 }
]

const loadStaffs = async () => {
  loading.value = true
  try {
    const res = await staffApi.getList()
    if (res.code === 0) {
      staffs.value = res.data || []
    }
  } catch (e) {
    Message.error('加载失败')
  } finally {
    loading.value = false
  }
}

const handleEdit = (record) => {
  editingId.value = record.id
  Object.assign(form, record)
  showForm.value = true
}

const handleSubmit = async (done) => {
  try {
    if (editingId.value) {
      await staffApi.update(editingId.value, form)
      Message.success('修改成功')
    } else {
      await staffApi.create(form)
      Message.success('创建成功')
    }
    showForm.value = false
    loadStaffs()
    done(true)
  } catch (e) {
    Message.error('操作失败')
    done(false)
  }
}

const handleDelete = async (id) => {
  try {
    await staffApi.delete(id)
    Message.success('删除成功')
    loadStaffs()
  } catch (e) {
    Message.error('删除失败')
  }
}

const resetForm = () => {
  editingId.value = null
  Object.assign(form, { name: '', phone: '', email: '', level: 3, remark: '' })
}

onMounted(() => {
  loadStaffs()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.level-desc {
  margin-top: 8px;
  color: #86909c;
  font-size: 12px;
}
</style>
