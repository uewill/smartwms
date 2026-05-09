<template>
  <div class="inbound">
    <a-card>
      <template #title>
        <div class="card-header">
          <span>入库单</span>
          <a-button type="primary" @click="showForm = true">
            <template #icon><IconPlus /></template>
            新建入库
          </a-button>
        </div>
      </template>

      <a-table :columns="columns" :data="orders" :loading="loading" :pagination="pagination" @page-change="handlePageChange">
        <template #status="{ record }">
          <a-tag :color="statusColors[record.status]">{{ statusText[record.status] }}</a-tag>
        </template>
        <template #actions="{ record }">
          <a-button type="text" size="small" @click="handleView(record)">查看</a-button>
          <a-button v-if="record.status === 'pending'" type="text" size="small" @click="handleApprove(record)">审核</a-button>
          <a-popconfirm v-if="record.status === 'pending'" content="确认删除？" @ok="handleDelete(record.id)">
            <a-button type="text" size="small" status="danger">删除</a-button>
          </a-popconfirm>
        </template>
      </a-table>
    </a-card>

    <a-modal v-model:visible="showForm" title="新建入库单" :width="700" @before-ok="handleSubmit" @cancel="resetForm">
      <a-form :model="form" layout="vertical">
        <a-form-item label="选择仓库" required>
          <a-select v-model="form.warehouseId" placeholder="请选择仓库" @change="onWarehouseChange">
            <a-option v-for="w in warehouses" :key="w.id" :value="w.id">{{ w.name }}</a-option>
          </a-select>
        </a-form-item>
        <a-form-item label="供应商">
          <a-input v-model="form.supplier" placeholder="请输入供应商" />
        </a-form-item>
        <a-form-item label="入库商品">
          <div v-for="(item, index) in form.items" :key="index" class="item-row">
            <a-select v-model="item.productId" placeholder="选择商品" style="flex: 2" @change="onProductChange(item)">
              <a-option v-for="p in products" :key="p.id" :value="p.id">{{ p.name }}</a-option>
            </a-select>
            <a-input-number v-model="item.quantity" placeholder="数量" style="flex: 1" :min="1" />
            <a-input-number v-model="item.price" placeholder="单价" style="flex: 1" :min="0" />
            <a-button type="text" status="danger" @click="removeItem(index)">删除</a-button>
          </div>
          <a-button type="dashed" long @click="addItem">+ 添加商品</a-button>
        </a-form-item>
        <a-form-item label="备注">
          <a-textarea v-model="form.remark" placeholder="备注" />
        </a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:visible="showDetail" title="入库单详情" :width="600">
      <a-descriptions :column="2" v-if="currentOrder">
        <a-descriptions-item label="单号">{{ currentOrder.orderNo }}</a-descriptions-item>
        <a-descriptions-item label="仓库">{{ currentOrder.warehouseName }}</a-descriptions-item>
        <a-descriptions-item label="供应商">{{ currentOrder.supplier }}</a-descriptions-item>
        <a-descriptions-item label="总数量">{{ currentOrder.totalQuantity }}</a-descriptions-item>
        <a-descriptions-item label="总金额">¥{{ currentOrder.totalAmount }}</a-descriptions-item>
        <a-descriptions-item label="状态">
          <a-tag :color="statusColors[currentOrder.status]">{{ statusText[currentOrder.status] }}</a-tag>
        </a-descriptions-item>
        <a-descriptions-item label="操作人">{{ currentOrder.operatorName }}</a-descriptions-item>
        <a-descriptions-item label="创建时间">{{ currentOrder.createdAt }}</a-descriptions-item>
      </a-descriptions>
      <a-divider>商品明细</a-divider>
      <a-table :columns="itemColumns" :data="currentOrder?.items || []" :pagination="false" size="small" />
    </a-modal>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { inboundApi, warehouseApi, productApi } from '../../api'
import { useAuthStore } from '../../store/auth'
import { Message } from '@arco-design/web-vue'
import { IconPlus } from '@arco-design/web-vue/es/icon'

const authStore = useAuthStore()
const loading = ref(false)
const orders = ref([])
const warehouses = ref([])
const products = ref([])
const showForm = ref(false)
const showDetail = ref(false)
const currentOrder = ref(null)

const form = reactive({
  warehouseId: null,
  warehouseName: '',
  supplier: '',
  remark: '',
  items: [{ productId: null, productName: '', productCode: '', quantity: 1, price: 0 }]
})

const pagination = reactive({ current: 1, pageSize: 10, total: 0 })

const statusText = { pending: '待审核', approved: '已审核', completed: '已完成', cancelled: '已取消' }
const statusColors = { pending: 'orange', approved: 'blue', completed: 'green', cancelled: 'default' }

const columns = [
  { title: '单号', dataIndex: 'orderNo', width: 180 },
  { title: '仓库', dataIndex: 'warehouseName', width: 120 },
  { title: '供应商', dataIndex: 'supplier', width: 120 },
  { title: '数量', dataIndex: 'totalQuantity', width: 80 },
  { title: '金额', dataIndex: 'totalAmount', width: 100 },
  { title: '状态', slotName: 'status', width: 100 },
  { title: '创建时间', dataIndex: 'createdAt', width: 160 },
  { title: '操作', slotName: 'actions', width: 180 }
]

const itemColumns = [
  { title: '商品', dataIndex: 'productName' },
  { title: '编码', dataIndex: 'productCode' },
  { title: '数量', dataIndex: 'quantity' },
  { title: '单价', dataIndex: 'price' }
]

const loadData = async () => {
  loading.value = true
  try {
    const [ordersRes, warehouseRes, productRes] = await Promise.all([
      inboundApi.getList(),
      warehouseApi.getList(),
      productApi.getList()
    ])
    if (ordersRes.code === 0) orders.value = ordersRes.data || []
    if (warehouseRes.code === 0) warehouses.value = warehouseRes.data || []
    if (productRes.code === 0) products.value = productRes.data || []
    pagination.total = orders.value.length
  } finally {
    loading.value = false
  }
}

const onWarehouseChange = (id) => {
  const w = warehouses.value.find(w => w.id === id)
  if (w) form.warehouseName = w.name
}

const onProductChange = (item) => {
  const p = products.value.find(p => p.id === item.productId)
  if (p) {
    item.productName = p.name
    item.productCode = p.code
    item.price = p.costPrice
  }
}

const addItem = () => {
  form.items.push({ productId: null, productName: '', productCode: '', quantity: 1, price: 0 })
}

const removeItem = (index) => {
  if (form.items.length > 1) form.items.splice(index, 1)
}

const handleSubmit = async (done) => {
  if (!form.warehouseId) {
    Message.warning('请选择仓库')
    done(false)
    return
  }
  const validItems = form.items.filter(i => i.productId && i.quantity > 0)
  if (validItems.length === 0) {
    Message.warning('请添加商品')
    done(false)
    return
  }
  try {
    await inboundApi.create({
      ...form,
      items: validItems,
      operatorId: authStore.staff?.id,
      operatorName: authStore.staff?.name
    })
    Message.success('创建成功')
    showForm.value = false
    loadData()
    done(true)
  } catch (e) {
    Message.error('创建失败')
    done(false)
  }
}

const handleView = async (record) => {
  const res = await inboundApi.get(record.id)
  if (res.code === 0) {
    currentOrder.value = res.data
    showDetail.value = true
  }
}

const handleApprove = async (record) => {
  try {
    await inboundApi.updateStatus(record.id, 'completed')
    Message.success('审核成功')
    loadData()
  } catch (e) {
    Message.error('审核失败')
  }
}

const handleDelete = async (id) => {
  try {
    await inboundApi.delete(id)
    Message.success('删除成功')
    loadData()
  } catch (e) {
    Message.error('删除失败')
  }
}

const resetForm = () => {
  form.warehouseId = null
  form.warehouseName = ''
  form.supplier = ''
  form.remark = ''
  form.items = [{ productId: null, productName: '', productCode: '', quantity: 1, price: 0 }]
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.item-row {
  display: flex;
  gap: 8px;
  margin-bottom: 8px;
  align-items: center;
}
</style>
