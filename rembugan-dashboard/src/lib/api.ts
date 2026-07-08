// API utilities for backend integration
export const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000'
export const APP_URL = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'

function getAuthHeaders() {
  const token = typeof window !== 'undefined' ? sessionStorage.getItem('admin_token') : null
  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  if (token) {
    headers['Authorization'] = `Bearer ${token}`
  }
  return headers
}

export async function fetchDashboardStats() {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/stats`, { headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to fetch stats')
    return response.json()
  } catch (error) {
    console.error('Error fetching stats:', error)
    return { status: 'error', data: { total_users: 0, active_projects: 0, scraped_competitions: 0 } }
  }
}

export async function fetchUsers(skip = 0, limit = 50) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/users?skip=${skip}&limit=${limit}`, { headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to fetch users')
    return response.json()
  } catch (error) {
    console.error('Error fetching users:', error)
    return { status: 'error', data: [] }
  }
}

export async function fetchProjects(skip = 0, limit = 50) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/projects?skip=${skip}&limit=${limit}`, { headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to fetch projects')
    return response.json()
  } catch (error) {
    console.error('Error fetching projects:', error)
    return { status: 'error', data: [] }
  }
}

export async function fetchShowcases(skip = 0, limit = 50) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/showcases?skip=${skip}&limit=${limit}`, { headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to fetch showcases')
    return response.json()
  } catch (error) {
    console.error('Error fetching showcases:', error)
    return { status: 'error', data: [] }
  }
}

export async function fetchTasks(skip = 0, limit = 50) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/tasks?skip=${skip}&limit=${limit}`, { headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to fetch tasks')
    return response.json()
  } catch (error) {
    console.error('Error fetching tasks:', error)
    return { status: 'error', data: [] }
  }
}

export async function fetchApplications(skip = 0, limit = 50) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/applications?skip=${skip}&limit=${limit}`, { headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to fetch applications')
    return response.json()
  } catch (error) {
    console.error('Error fetching applications:', error)
    return { status: 'error', data: [] }
  }
}

export async function fetchCompetitions() {
  try {
    const response = await fetch(`${API_BASE_URL}/competitions/all`, { headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to fetch competitions')
    return response.json()
  } catch (error) {
    console.error('Error fetching competitions:', error)
    return { status: 'error', data: [] }
  }
}

export async function createUser(data: { email?: string; full_name: string; interest?: string; password: string; nim?: string; faculty?: string; major?: string }) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/users`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    })
    if (!response.ok) throw new Error('Failed to create user')
    return response.json()
  } catch (error) {
    console.error('Error creating user:', error)
    return { status: 'error', detail: 'Network error' }
  }
}

export async function importUsers(data: { users: Array<{ nim: string; full_name: string; faculty: string; major: string; interest?: string }>; default_password: string }) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/users/import`, {
      method: 'POST',
      headers: getAuthHeaders(),
      body: JSON.stringify(data),
    })
    if (!response.ok) throw new Error('Failed to import users')
    return response.json()
  } catch (error) {
    console.error('Error importing users:', error)
    return { status: 'error', detail: 'Network error' }
  }
}

// DELETE endpoints
export async function deleteUser(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/users/${id}`, { method: 'DELETE', headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to delete user')
    return response.json()
  } catch (error) {
    console.error('Error deleting user:', error)
    return { status: 'error' }
  }
}

export async function deleteProject(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/projects/${id}`, { method: 'DELETE', headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to delete project')
    return response.json()
  } catch (error) {
    console.error('Error deleting project:', error)
    return { status: 'error' }
  }
}

export async function deleteShowcase(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/showcases/${id}`, { method: 'DELETE', headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to delete showcase')
    return response.json()
  } catch (error) {
    console.error('Error deleting showcase:', error)
    return { status: 'error' }
  }
}

export async function deleteTask(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/tasks/${id}`, { method: 'DELETE', headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to delete task')
    return response.json()
  } catch (error) {
    console.error('Error deleting task:', error)
    return { status: 'error' }
  }
}

export async function deleteApplication(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/applications/${id}`, { method: 'DELETE', headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to delete application')
    return response.json()
  } catch (error) {
    console.error('Error deleting application:', error)
    return { status: 'error' }
  }
}

export async function fetchCompetitionsStats() {
  try {
    const response = await fetch(`${API_BASE_URL}/competitions/stats`, { headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to fetch competition stats')
    return response.json()
  } catch (error) {
    console.error('Error fetching competition stats:', error)
    return { status: 'error', data: { by_source: [], by_deadline: [], by_kategori: [] } }
  }
}

export async function fetchShowcaseById(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/showcase/${id}`, { headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to fetch showcase')
    return response.json()
  } catch (error) {
    console.error('Error fetching showcase:', error)
    return { status: 'error', data: null }
  }
}

export async function deleteCompetition(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/competitions/${id}`, { method: 'DELETE', headers: getAuthHeaders() })
    if (!response.ok) throw new Error('Failed to delete competition')
    return response.json()
  } catch (error) {
    console.error('Error deleting competition:', error)
    return { status: 'error' }
  }
}