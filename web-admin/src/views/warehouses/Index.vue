<template>
  <div class="warehouses">
    <a-card>
      <template #title>
        <div class="card-header">
          <span>仓库管理</span>
          <a-button type="primary" @click="showForm = true">
            <template #icon><IconPlus /></template>
            新建仓库
          </a-button>
        </div>
      </template>

      <a-table :columns="columns" :data="warehouses" :loading="loading">
        <template #status="{ record }">
          <a-tag :color="record.status === 'active' ? 'green' : 'default'">
            {{ record.status === 'active' ? '正常' : '停用' }}
          </a-tag>
        </template>
        <template #actions="{ record }">
          <a-button type="text" size="small" @click="handleEdit(record)">编辑</a-button>
          <a-popconfirm content="确认删除此仓库？" @ok="handleDelete(record.id)">
            <a-button type="text" size="small" status="danger">删除</a-button>
          </a-popconfirm>
        </template>
      </a-table>
    </a-card>

    <a-modal v-model:visible="showForm" :title="editingId ? '编辑仓库' : '新建仓库'" @before-ok="handleSubmit" @cancel="resetForm">
      <a-form :model="form" layout="vertical">
        <a-form-item label="仓库名称" required>
          <a-input v-model="form.name" placeholder="请输入仓库名称" />
        </a-form-item>
        <a-form-item label="仓库地址">
          <a-input v-model="form.address" placeholder="请输入仓库地址" />
        </a-form-item>
        <a-form-item label="联系人">
          <a-input v-model="form.contact" placeholder="请输入联系人" />
        </a-form-item>
        <a-form-item label="联系电话">
          <a-input v-model="form.phone" placeholder="请输入联系电话" />
        </a-form-item>
        <a-form-item label="状态">
          <a-select v-model="form.status">
            <a-option value="active">正常</a-option>
            <a-option value="inactive">停用</a-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { warehouseApi } from '../../api'
import { IconPlus } from '@arco-design/web-vue/es/icon'

const loading = ref(false)
const warehouses = ref([])
const showForm = ref(false)
const editingId = ref(null)

const form = reactive({
  name: '',
  address: '',
  contact: '',
  phone: '',
  status: 'active'
})

const columns = [
  { title: '名称', dataIndex: 'name' },
  { title: '地址', dataIndex: 'address' },
  { title: '联系人', dataIndex: 'contact', width: 100 },
  { title: '电话', dataIndex: 'phone', width: 130 },
  { title: '商品种类', dataIndex: 'productCount', width: 100 },
  { title: '总库存', dataIndex: 'totalStock', width: 100 },
  { title: '状态', slotName: 'status', width: 80 },
  { title: '操作', slotName: 'actions', width: 150 }
]

const loadWarehouses = async () => {
  loading.value = true
  try {
    const res = await warehouseApi.getList()
    if (res.code === 0) {
      warehouses.value = res.data || []
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
      await warehouseApi.update(editingId.value, form)
      Message.success('修改成功')
    } else {
      await warehouseApi.create(form)
      Message.success('创建成功')
    }
    showForm.value = false
    loadWarehouses()
    done(true)
  } catch (e) {
    Message.error('操作失败')
    done(false)
  }
}

const handleDelete = async (id) => {
  try {
    await warehouseApi.delete(id)
    Message.success('删除成功')
    loadWarehouses()
  } catch (e) {
    Message.error('删除失败')
  }
}

const resetForm = () => {
  editingId.value = null
  Object.assign(form, { name: '', address: '', contact: '', phone: '', status: 'active' })
}

onMounted(() => {
  loadWarehouses()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style>
