import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/auth/Login.vue')
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../views/auth/Register.vue')
  },
  {
    path: '/',
    component: () => import('../views/Layout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('../views/dashboard/Index.vue')
      },
      {
        path: 'products',
        name: 'Products',
        component: () => import('../views/products/Index.vue')
      },
      {
        path: 'warehouses',
        name: 'Warehouses',
        component: () => import('../views/warehouses/Index.vue')
      },
      {
        path: 'inbound',
        name: 'Inbound',
        component: () => import('../views/inbound/Index.vue')
      },
      {
        path: 'outbound',
        name: 'Outbound',
        component: () => import('../views/outbound/Index.vue')
      },
      {
        path: 'reports',
        name: 'Reports',
        component: () => import('../views/reports/Index.vue')
      },
      {
        path: 'staff',
        name: 'Staff',
        component: () => import('../views/staff/Index.vue')
      },
      {
        path: 'profile',
        name: 'Profile',
        component: () => import('../views/profile/Index.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (!token && to.path !== '/login' && to.path !== '/register') {
    next('/login')
  } else {
    next()
  }
})

export default router
