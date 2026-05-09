import { defineStore } from 'pinia'
import { authApi } from '../api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    staff: null,
    tenant: null,
    token: localStorage.getItem('token')
  }),

  getters: {
    isLoggedIn: state => !!state.token,
    canManageStaff: state => state.staff?.level === 1,
    canManageWarehouse: state => state.staff?.level <= 2,
    canManageProduct: state => state.staff?.level <= 2,
    canInbound: state => state.staff?.level <= 3,
    canOutbound: state => state.staff?.level <= 3
  },

  actions: {
    async loginByCode(phone, code) {
      const res = await authApi.loginByCode(phone, code)
      if (res.code === 0) {
        this.setAuth(res.data)
        return true
      }
      return false
    },

    async loginByPassword(phone, password) {
      const res = await authApi.loginByPassword(phone, password)
      if (res.code === 0) {
        this.setAuth(res.data)
        return true
      }
      return false
    },

    async register(data) {
      const res = await authApi.register(data)
      if (res.code === 0) {
        this.setAuth(res.data)
        return true
      }
      return false
    },

    setAuth(data) {
      this.token = data.token
      this.user = data.user
      this.staff = data.staff
      this.tenant = data.tenant
      localStorage.setItem('token', data.token)
    },

    async loadUserInfo() {
      const res = await authApi.getUserInfo()
      if (res.code === 0) {
        this.user = res.data.user
        this.staff = res.data.staff
        this.tenant = res.data.tenant
      }
    },

    async logout() {
      await authApi.logout()
      this.token = null
      this.user = null
      this.staff = null
      this.tenant = null
      localStorage.removeItem('token')
    }
  }
})
