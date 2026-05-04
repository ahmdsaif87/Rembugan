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