<template>
  <div class="dashboard">
    <a-row :gutter="16" class="stats-row">
      <a-col :span="6">
        <a-card class="stat-card">
          <div class="stat-content">
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalProducts }}</div>
              <div class="stat-label">商品种类</div>
            </div>
            <div class="stat-icon" style="background: #e6f7ff;">
              <IconApps style="color: #1890ff;" />
            </div>
          </div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card class="stat-card">
          <div class="stat-content">
            <div class="stat-info">
              <div class="stat-value">{{ stats.totalQuantity }}</div>
              <div class="stat-label">总库存量</div>
            </div>
            <div class="stat-icon" style="background: #f6ffed;">
              <IconLocation style="color: #52c41a;" />
            </div>
          </div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card class="stat-card">
          <div class="stat-content">
            <div class="stat-info">
              <div class="stat-value">{{ stats.pendingInbound }}</div>
              <div class="stat-label">待入库</div>
            </div>
            <div class="stat-icon" style="background: #fff7e6;">
              <IconDownload style="color: #fa8c16;" />
            </div>
          </div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card class="stat-card">
          <div class="stat-content">
            <div class="stat-info">
              <div class="stat-value">{{ stats.pendingOutbound }}</div>
              <div class="stat-label">待出库</div>
            </div>
            <div class="stat-icon" style="background: #fff1f0;">
              <IconUpload style="color: #ff4d4f;" />
            </div>
          </div>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="16">
        <a-card title="快捷操作">
          <a-row :gutter="16">
            <a-col :span="6">
              <div class="quick-action" @click="$router.push('/inbound')">
                <div class="action-icon" style="background: #e6f7ff;">
                  <IconDownload style="color: #1890ff;" />
                </div>
                <span>新建入库</span>
              </div>
            </a-col>
            <a-col :span="6">
              <div class="quick-action" @click="$router.push('/outbound')">
                <div class="action-icon" style="background: #fff7e6;">
                  <IconUpload style="color: #fa8c16;" />
                </div>
                <span>新建出库</span>
              </div>
            </a-col>
            <a-col :span="6">
              <div class="quick-action" @click="$router.push('/products')">
                <div class="action-icon" style="background: #f6ffed;">
                  <IconApps style="color: #52c41a;" />
                </div>
                <span>商品管理</span>
              </div>
            </a-col>
            <a-col :span="6">
              <div class="quick-action" @click="$router.push('/reports')">
                <div class="action-icon" style="background: #fff1f0;">
                  <IconBarChart style="color: #ff4d4f;" />
                </div>
                <span>查看报表</span>
              </div>
            </a-col>
          </a-row>
        </a-card>
      </a-col>

      <a-col :span="8">
        <a-card title="系统信息">
          <a-descriptions :column="1" size="small">
            <a-descriptions-item label="租户名称">{{ authStore.tenant?.name }}</a-descriptions-item>
            <a-descriptions-item label="当前用户">{{ authStore.staff?.name }}</a-descriptions-item>
            <a-descriptions-item label="用户级别">
              <a-tag :color="levelColor">{{ levelText }}</a-tag>
            </a-descriptions-item>
            <a-descriptions-item label="系统版本">v1.0.0</a-descriptions-item>
          </a-descriptions>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="16" style="margin-top: 16px;">
      <a-col :span="12">
        <a-card title="最近入库">
          <a-table :columns="inboundColumns" :data="recentInbound" :pagination="false" size="small">
            <template #status="{ record }">
              <a-tag :color="record.status === 'pending' ? 'orange' : 'green'">
                {{ record.status === 'pending' ? '待审核' : '已完成' }}
              </a-tag>
            </template>
          </a-table>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card title="最近出库">
          <a-table :columns="outboundColumns" :data="recentOutbound" :pagination="false" size="small">
            <template #status="{ record }">
              <a-tag :color="record.status === 'pending' ? 'orange' : 'green'">
                {{ record.status === 'pending' ? '待审核' : '已完成' }}
              </a-tag>
            </template>
          </a-table>
        </a-card>
      </a-col>
    </a-row>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../../store/auth'
import { reportApi, inboundApi, outboundApi } from '../../api'
import { IconApps, IconLocation, IconDownload, IconUpload, IconBarChart } from '@arco-design/web-vue/es/icon'

const authStore = useAuthStore()

const stats = ref({
  totalProducts: 0,
  totalQuantity: 0,
  pendingInbound: 0,
  pendingOutbound: 0
})

const recentInbound = ref([])
const recentOutbound = ref([])

const levelText = computed(() => {
  const levels = { 1: '超级管理员', 2: '管理员', 3: '操作员', 4: '查看者' }
  return levels[authStore.staff?.level] || ''
})

const levelColor = computed(() => {
  const colors = { 1: 'red', 2: 'blue', 3: 'green', 4: 'orange' }
  return colors[authStore.staff?.level] || 'default'
})

const inboundColumns = [
  { title: '单号', dataIndex: 'orderNo' },
  { title: '仓库', dataIndex: 'warehouseName' },
  { title: '数量', dataIndex: 'totalQuantity' },
  { title: '状态', slotName: 'status' }
]

const outboundColumns = [
  { title: '单号', dataIndex: 'orderNo' },
  { title: '仓库', dataIndex: 'warehouseName' },
  { title: '数量', dataIndex: 'totalQuantity' },
  { title: '状态', slotName: 'status' }
]

onMounted(async () => {
  try {
    const dashRes = await reportApi.getDashboard()
    if (dashRes.code === 0) {
      stats.value = dashRes.data
    }

    const inboundRes = await inboundApi.getList()
    if (inboundRes.code === 0) {
      recentInbound.value = (inboundRes.data || []).slice(0, 5)
    }

    const outboundRes = await outboundApi.getList()
    if (outboundRes.code === 0) {
      recentOutbound.value = (outboundRes.data || []).slice(0, 5)
    }
  } catch (e) {
    console.error(e)
  }
})
</script>

<style scoped>
.stats-row .arco-col {
  margin-bottom: 16px;
}

.stat-card {
  border-radius: 8px;
}

.stat-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #1d2129;
}

.stat-label {
  color: #86909c;
  font-size: 14px;
  margin-top: 4px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-icon svg {
  width: 24px;
  height: 24px;
}

.quick-action {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px;
  cursor: pointer;
  border-radius: 8px;
  transition: background 0.2s;
}

.quick-action:hover {
  background: #f2f3f5;
}

.action-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-icon svg {
  width: 24px;
  height: 24px;
}
</style>
