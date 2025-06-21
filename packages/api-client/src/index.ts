// Shared API client for all micro-apps (<50 lines)
// In production, use relative /api path so nginx can proxy to backend
const API_BASE = typeof window !== 'undefined' && window.location.hostname !== 'localhost' 
  ? '/api' 
  : (process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3100');

// Auth token management  
let authToken: string | null = null;

export const setAuthToken = (token: string) => {
  authToken = token;
  if (typeof window !== 'undefined') {
    localStorage.setItem('authToken', token);
  }
};

export const getAuthToken = () => {
  if (!authToken && typeof window !== 'undefined') {
    authToken = localStorage.getItem('authToken');
  }
  return authToken;
};

// Generic fetch wrapper
export const apiFetch = async (endpoint: string, options: RequestInit = {}) => {
  const token = getAuthToken();
  
  const res = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options.headers,
    },
  });
  
  if (!res.ok) {
    throw new Error(`API Error: ${res.status}`);
  }
  
  return res.json();
};

// SWR fetcher
export const fetcher = (url: string) => apiFetch(url);

// Login helper
export const login = async (email: string, password: string) => {
  const data = await apiFetch('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });
  
  if (data.token) {
    setAuthToken(data.token);
  }
  
  return data;
};