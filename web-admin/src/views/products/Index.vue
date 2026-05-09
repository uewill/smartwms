<template>
  <div class="products">
    <a-card>
      <template #title>
        <div class="card-header">
          <span>商品管理</span>
          <a-button type="primary" @click="showForm = true">
            <template #icon><IconPlus /></template>
            新建商品
          </a-button>
        </div>
      </template>

      <div class="toolbar">
        <a-input-search placeholder="搜索商品名称/编码" style="width: 300px" @search="handleSearch" />
      </div>

      <a-table :columns="columns" :data="products" :loading="loading" :pagination="pagination" @page-change="handlePageChange">
        <template #status="{ record }">
          <a-tag :color="record.status === 'active' ? 'green' : 'default'">
            {{ record.status === 'active' ? '启用' : '停用' }}
          </a-tag>
        </template>
        <template #stock="{ record }">
          <span :style="{ color: record.stockQuantity < record.warningStock ? '#ff4d4f' : '#52c41a' }">
            {{ record.stockQuantity }}
          </span>
        </template>
        <template #actions="{ record }">
          <a-button type="text" size="small" @click="handleEdit(record)">编辑</a-button>
          <a-popconfirm content="确认删除此商品？" @ok="handleDelete(record.id)">
            <a-button type="text" size="small" status="danger">删除</a-button>
          </a-popconfirm>
        </template>
      </a-table>
    </a-card>

    <a-modal v-model:visible="showForm" :title="editingId ? '编辑商品' : '新建商品'" @before-ok="handleSubmit" @cancel="resetForm">
      <a-form :model="form" layout="vertical">
        <a-form-item label="商品编码" required>
          <a-input v-model="form.code" placeholder="请输入商品编码" />
        </a-form-item>
        <a-form-item label="商品名称" required>
          <a-input v-model="form.name" placeholder="请输入商品名称" />
        </a-form-item>
        <a-form-item label="规格型号">
          <a-input v-model="form.spec" placeholder="请输入规格型号" />
        </a-form-item>
        <a-form-item label="单位">
          <a-input v-model="form.unit" placeholder="请输入单位" />
        </a-form-item>
        <a-form-item label="售价">
          <a-input-number v-model="form.price" placeholder="0.00" style="width: 100%" />
        </a-form-item>
        <a-form-item label="成本价">
          <a-input-number v-model="form.costPrice" placeholder="0.00" style="width: 100%" />
        </a-form-item>
        <a-form-item label="库存预警值">
          <a-input-number v-model="form.warningStock" placeholder="0" style="width: 100%" />
        </a-form-item>
        <a-form-item label="商品分类">
          <a-input v-model="form.category" placeholder="请输入商品分类" />
        </a-form-item>
        <a-form-item label="备注">
          <a-textarea v-model="form.remark" placeholder="请输入备注" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { productApi } from '../../api'
import { IconPlus } from '@arco-design/web-vue/es/icon'

const loading = ref(false)
const products = ref([])
const showForm = ref(false)
const editingId = ref(null)

const form = reactive({
  code: '',
  name: '',
  spec: '',
  unit: '个',
  price: 0,
  costPrice: 0,
  warningStock: 0,
  category: '',
  remark: ''
})

const pagination = reactive({
  current: 1,
  pageSize: 10,
  total: 0
})

const columns = [
  { title: '编码', dataIndex: 'code', width: 120 },
  { title: '名称', dataIndex: 'name' },
  { title: '规格', dataIndex: 'spec', width: 100 },
  { title: '单位', dataIndex: 'unit', width: 80 },
  { title: '售价', dataIndex: 'price', width: 100 },
  { title: '成本价', dataIndex: 'costPrice', width: 100 },
  { title: '库存', slotName: 'stock', width: 100 },
  { title: '分类', dataIndex: 'category', width: 100 },
  { title: '状态', slotName: 'status', width: 80 },
  { title: '操作', slotName: 'actions', width: 150 }
]

const loadProducts = async () => {
  loading.value = true
  try {
    const res = await productApi.getList()
    if (res.code === 0) {
      products.value = res.data || []
      pagination.total = products.value.length
    }
  } catch (e) {
    Message.error('加载失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = async (value) => {
  loading.value = true
  try {
    const res = await productApi.getList(value)
    if (res.code === 0) {
      products.value = res.data || []
    }
  } finally {
    loading.value = false
  }
}

const handlePageChange = (page) => {
  pagination.current = page
  loadProducts()
}

const handleEdit = (record) => {
  editingId.value = record.id
  Object.assign(form, record)
  showForm.value = true
}

const handleSubmit = async (done) => {
  try {
    if (editingId.value) {
      await productApi.update(editingId.value, form)
      Message.success('修改成功')
    } else {
      await productApi.create(form)
      Message.success('创建成功')
    }
    showForm.value = false
    loadProducts()
    done(true)
  } catch (e) {
    Message.error('操作失败')
    done(false)
  }
}

const handleDelete = async (id) => {
  try {
    await productApi.delete(id)
    Message.success('删除成功')
    loadProducts()
  } catch (e) {
    Message.error('删除失败')
  }
}

const resetForm = () => {
  editingId.value = null
  Object.assign(form, {
    code: '', name: '', spec: '', unit: '个', price: 0,
    costPrice: 0, warningStock: 0, category: '', remark: ''
  })
}

onMounted(() => {
  loadProducts()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.toolbar {
  margin-bottom: 16px;
}
</style>
