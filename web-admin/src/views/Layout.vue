<template>
  <div class="layout">
    <a-layout>
      <a-layout-sider :width="220" :collapsed="collapsed" collapsible @collapse="collapsed = !collapsed">
        <div class="logo">
          <span v-if="!collapsed">SmartWMS</span>
          <span v-else>SW</span>
        </div>
        <a-menu :selected-keys="[currentRoute]" @menu-item-click="handleMenuClick">
          <a-menu-item key="/dashboard">
            <template #icon><IconDashboard /></template>
            <span>工作台</span>
          </a-menu-item>
          <a-menu-item key="/products">
            <template #icon><IconApps /></template>
            <span>商品管理</span>
          </a-menu-item>
          <a-menu-item key="/warehouses">
            <template #icon><IconLocation /></template>
            <span>仓库管理</span>
          </a-menu-item>
          <a-menu-item key="/inbound">
            <template #icon><IconDownload /></template>
            <span>入库单</span>
          </a-menu-item>
          <a-menu-item key="/outbound">
            <template #icon><IconUpload /></template>
            <span>出库单</span>
          </a-menu-item>
          <a-menu-item key="/reports">
            <template #icon><IconBarChart /></template>
            <span>数据报表</span>
          </a-menu-item>
          <a-sub-menu v-if="canManageStaff" key="system">
            <template #icon><IconSettings /></template>
            <span>系统管理</span>
            <a-menu-item key="/staff">职员管理</a-menu-item>
          </a-sub-menu>
        </a-menu>
      </a-layout-sider>

      <a-layout>
        <a-layout-header class="header">
          <div class="header-left">
            <a-button type="text" @click="collapsed = !collapsed">
              <template #icon><IconMenu /></template>
            </a-button>
            <a-breadcrumb>
              <a-breadcrumb-item>{{ currentMenu }}</a-breadcrumb-item>
            </a-breadcrumb>
          </div>
          <div class="header-right">
            <a-dropdown @select="handleUserMenu">
              <a-button type="text">
                <template #icon><IconUser /></template>
                {{ authStore.staff?.name || authStore.user?.nickname }}
              </a-button>
              <template #content>
                <a-doption key="profile">个人中心</a-doption>
                <a-doption key="logout">退出登录</a-doption>
              </template>
            </a-dropdown>
          </div>
        </a-layout-header>

        <a-layout-content class="content">
          <router-view />
        </a-layout-content>
      </a-layout>
    </a-layout>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../store/auth'
import { IconDashboard, IconApps, IconLocation, IconDownload, IconUpload, IconBarChart, IconSettings, IconMenu, IconUser } from '@arco-design/web-vue/es/icon'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const collapsed = ref(false)

const canManageStaff = computed(() => authStore.canManageStaff)

const currentRoute = computed(() => route.path)

const currentMenu = computed(() => {
  const menus = {
    '/dashboard': '工作台',
    '/products': '商品管理',
    '/warehouses': '仓库管理',
    '/inbound': '入库单',
    '/outbound': '出库单',
    '/reports': '数据报表',
    '/staff': '职员管理',
    '/profile': '个人中心'
  }
  return menus[route.path] || ''
})

const handleMenuClick = (key) => {
  router.push(key)
}

const handleUserMenu = (key) => {
  if (key === 'logout') {
    authStore.logout()
    router.push('/login')
  } else if (key === 'profile') {
    router.push('/profile')
  }
}

onMounted(() => {
  if (!authStore.staff) {
    authStore.loadUserInfo()
  }
})
</script>

<style scoped>
.layout {
  height: 100vh;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
  font-size: 18px;
  font-weight: bold;
}

.header {
  background: #fff;
  padding: 0 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.content {
  margin: 16px;
  min-height: calc(100vh - 60px - 32px);
}
</style>
