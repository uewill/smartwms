<template>
  <div class="reports">
    <a-tabs>
      <a-tab-pane title="库存报表">
        <a-card>
          <a-row :gutter="16">
            <a-col :span="6">
              <a-statistic title="商品种类" :value="inventoryReport.totalProductTypes" />
            </a-col>
            <a-col :span="6">
              <a-statistic title="总库存量" :value="inventoryReport.totalQuantity" />
            </a-col>
          </a-row>
        </a-card>
        <a-card title="低库存预警" style="margin-top: 16px" v-if="inventoryReport.lowStockProducts?.length">
          <a-table :columns="lowStockColumns" :data="inventoryReport.lowStockProducts" :pagination="false" size="small" />
        </a-card>
        <a-card title="库存明细" style="margin-top: 16px">
          <a-table :columns="inventoryColumns" :data="inventoryReport.productInventory || []" :pagination="{ pageSize: 10 }" />
        </a-card>
      </a-tab-pane>

      <a-tab-pane title="成本报表">
        <a-card>
          <a-row :gutter="16">
            <a-col :span="6">
              <a-statistic title="本月入库成本" prefix="¥" :value="costReport.monthInboundCost" :precision="2" />
            </a-col>
            <a-col :span="6">
              <a-statistic title="本月出库成本" prefix="¥" :value="costReport.monthOutboundCost" :precision="2" />
            </a-col>
            <a-col :span="6">
              <a-statistic title="库存总价值" prefix="¥" :value="costReport.totalInventoryValue" :precision="2" />
            </a-col>
            <a-col :span="6">
              <a-statistic title="平均成本" prefix="¥" :value="costReport.averageCost" :precision="2" />
            </a-col>
          </a-row>
        </a-card>
        <a-card title="成本趋势" style="margin-top: 16px">
          <a-table :columns="trendColumns" :data="costReport.monthlyTrend || []" :pagination="false" size="small">
            <template #inboundCost="{ record }">
              <span style="color: #52c41a">¥{{ record.inboundCost }}</span>
            </template>
            <template #outboundCost="{ record }">
              <span style="color: #ff4d4f">¥{{ record.outboundCost }}</span>
            </template>
          </a-table>
        </a-card>
      </a-tab-pane>
    </a-tabs>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { reportApi } from '../../api'

const inventoryReport = ref({
  totalProductTypes: 0,
  totalQuantity: 0,
  lowStockProducts: [],
  productInventory: []
})

const costReport = ref({
  monthInboundCost: 0,
  monthOutboundCost: 0,
  totalInventoryValue: 0,
  averageCost: 0,
  monthlyTrend: []
})

const lowStockColumns = [
  { title: '商品名称', dataIndex: 'name' },
  { title: '编码', dataIndex: 'code' },
  { title: '当前库存', dataIndex: 'stockQuantity' },
  { title: '预警值', dataIndex: 'warningStock' }
]

const inventoryColumns = [
  { title: '商品', dataIndex: 'productName' },
  { title: '仓库', dataIndex: 'warehouseName' },
  { title: '库存', dataIndex: 'quantity' }
]

const trendColumns = [
  { title: '月份', dataIndex: 'month' },
  { title: '入库成本', slotName: 'inboundCost' },
  { title: '出库成本', slotName: 'outboundCost' }
]

onMounted(async () => {
  try {
    const [invRes, costRes] = await Promise.all([
      reportApi.getInventoryReport(),
      reportApi.getCostReport()
    ])
    if (invRes.code === 0) inventoryReport.value = invRes.data
    if (costRes.code === 0) costReport.value = costRes.data
  } catch (e) {
    console.error(e)
  }
})
</script>
