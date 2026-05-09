import axios from 'axios'

// API 地址配置 - 部署时修改此处
const BASE_URL = 'http://localhost:8080/api'

const api = axios.create({
  baseURL: BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json'
  }
})

api.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

api.interceptors.response.use(
  response => response.data,
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default {
  get(url, params) {
    return api.get(url, { params })
  },
  post(url, data) {
    return api.post(url, data)
  },
  put(url, data) {
    return api.put(url, data)
  },
  delete(url) {
    return api.delete(url)
  }
}
