// API utilities for backend integration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000'

// Admin endpoints don't require authentication for demo
const headers = {
  'Content-Type': 'application/json',
}

export async function fetchDashboardStats() {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/stats`, { headers })
    if (!response.ok) throw new Error('Failed to fetch stats')
    return response.json()
  } catch (error) {
    console.error('Error fetching stats:', error)
    return { status: 'error', data: { total_users: 0, active_projects: 0, scraped_competitions: 0 } }
  }
}

export async function fetchUsers(skip = 0, limit = 50) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/users?skip=${skip}&limit=${limit}`, { headers })
    if (!response.ok) throw new Error('Failed to fetch users')
    return response.json()
  } catch (error) {
    console.error('Error fetching users:', error)
    return { status: 'error', data: [] }
  }
}

export async function fetchProjects(skip = 0, limit = 50) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/projects?skip=${skip}&limit=${limit}`, { headers })
    if (!response.ok) throw new Error('Failed to fetch projects')
    return response.json()
  } catch (error) {
    console.error('Error fetching projects:', error)
    return { status: 'error', data: [] }
  }
}

export async function fetchShowcases(skip = 0, limit = 50) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/showcases?skip=${skip}&limit=${limit}`, { headers })
    if (!response.ok) throw new Error('Failed to fetch showcases')
    return response.json()
  } catch (error) {
    console.error('Error fetching showcases:', error)
    return { status: 'error', data: [] }
  }
}

export async function fetchTasks(skip = 0, limit = 50) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/tasks?skip=${skip}&limit=${limit}`, { headers })
    if (!response.ok) throw new Error('Failed to fetch tasks')
    return response.json()
  } catch (error) {
    console.error('Error fetching tasks:', error)
    return { status: 'error', data: [] }
  }
}

export async function fetchApplications(skip = 0, limit = 50) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/applications?skip=${skip}&limit=${limit}`, { headers })
    if (!response.ok) throw new Error('Failed to fetch applications')
    return response.json()
  } catch (error) {
    console.error('Error fetching applications:', error)
    return { status: 'error', data: [] }
  }
}

export async function fetchCompetitions() {
  try {
    const response = await fetch(`${API_BASE_URL}/competitions/all`, { headers })
    if (!response.ok) throw new Error('Failed to fetch competitions')
    return response.json()
  } catch (error) {
    console.error('Error fetching competitions:', error)
    return { status: 'error', data: [] }
  }
}

// DELETE endpoints
export async function deleteUser(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/users/${id}`, { method: 'DELETE', headers })
    if (!response.ok) throw new Error('Failed to delete user')
    return response.json()
  } catch (error) {
    console.error('Error deleting user:', error)
    return { status: 'error' }
  }
}

export async function deleteProject(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/projects/${id}`, { method: 'DELETE', headers })
    if (!response.ok) throw new Error('Failed to delete project')
    return response.json()
  } catch (error) {
    console.error('Error deleting project:', error)
    return { status: 'error' }
  }
}

export async function deleteShowcase(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/showcases/${id}`, { method: 'DELETE', headers })
    if (!response.ok) throw new Error('Failed to delete showcase')
    return response.json()
  } catch (error) {
    console.error('Error deleting showcase:', error)
    return { status: 'error' }
  }
}

export async function deleteTask(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/tasks/${id}`, { method: 'DELETE', headers })
    if (!response.ok) throw new Error('Failed to delete task')
    return response.json()
  } catch (error) {
    console.error('Error deleting task:', error)
    return { status: 'error' }
  }
}

export async function deleteApplication(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/applications/${id}`, { method: 'DELETE', headers })
    if (!response.ok) throw new Error('Failed to delete application')
    return response.json()
  } catch (error) {
    console.error('Error deleting application:', error)
    return { status: 'error' }
  }
}

export async function deleteCompetition(id: string) {
  try {
    const response = await fetch(`${API_BASE_URL}/admin/competitions/${id}`, { method: 'DELETE', headers })
    if (!response.ok) throw new Error('Failed to delete competition')
    return response.json()
  } catch (error) {
    console.error('Error deleting competition:', error)
    return { status: 'error' }
  }
}