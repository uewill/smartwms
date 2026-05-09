import request from '../utils/request'

export const authApi = {
  sendCode(phone, type = 'login') {
    return request.post('/auth/send-code', null, { params: { phone, type } })
  },
  loginByCode(phone, code) {
    return request.post('/auth/login-by-code', { phone, code })
  },
  loginByPassword(phone, password) {
    return request.post('/auth/login-by-pwd', { phone, password })
  },
  register(data) {
    return request.post('/auth/register', data)
  },
  wxLogin(wxOpenid) {
    return request.post('/auth/wx-login', { wx_openid: wxOpenid })
  },
  getUserInfo() {
    return request.get('/auth/user-info')
  },
  changePassword(oldPassword, newPassword) {
    return request.post('/auth/change-password', { oldPassword, newPassword })
  },
  getOperationLogs() {
    return request.get('/auth/operation-logs')
  },
  logout() {
    return request.post('/auth/logout')
  }
}

export const productApi = {
  getList(keyword, category) {
    return request.get('/products', { keyword, category })
  },
  get(id) {
    return request.get(`/products/${id}`)
  },
  create(data) {
    return request.post('/products', data)
  },
  update(id, data) {
    return request.put(`/products/${id}`, data)
  },
  delete(id) {
    return request.delete(`/products/${id}`)
  },
  getLowStock() {
    return request.get('/products/low-stock')
  }
}

export const warehouseApi = {
  getList() {
    return request.get('/warehouses')
  },
  get(id) {
    return request.get(`/warehouses/${id}`)
  },
  create(data) {
    return request.post('/warehouses', data)
  },
  update(id, data) {
    return request.put(`/warehouses/${id}`, data)
  },
  delete(id) {
    return request.delete(`/warehouses/${id}`)
  },
  getStats() {
    return request.get('/warehouses/stats')
  }
}

export const inboundApi = {
  getList() {
    return request.get('/inbound')
  },
  get(id) {
    return request.get(`/inbound/${id}`)
  },
  create(data) {
    return request.post('/inbound', data)
  },
  updateStatus(id, status) {
    return request.post(`/inbound/${id}/status`, { status })
  },
  delete(id) {
    return request.delete(`/inbound/${id}`)
  }
}

export const outboundApi = {
  getList() {
    return request.get('/outbound')
  },
  get(id) {
    return request.get(`/outbound/${id}`)
  },
  create(data) {
    return request.post('/outbound', data)
  },
  updateStatus(id, status) {
    return request.post(`/outbound/${id}/status`, { status })
  },
  delete(id) {
    return request.delete(`/outbound/${id}`)
  }
}

export const reportApi = {
  getDashboard() {
    return request.get('/reports/dashboard')
  },
  getInventoryReport() {
    return request.get('/reports/inventory')
  },
  getCostReport() {
    return request.get('/reports/cost')
  }
}

export const staffApi = {
  getList() {
    return request.get('/staffs')
  },
  get(id) {
    return request.get(`/staffs/${id}`)
  },
  create(data) {
    return request.post('/staffs', data)
  },
  update(id, data) {
    return request.put(`/staffs/${id}`, data)
  },
  delete(id) {
    return request.delete(`/staffs/${id}`)
  },
  resetPassword(id) {
    return request.put(`/staffs/${id}/reset-pwd`)
  }
}
