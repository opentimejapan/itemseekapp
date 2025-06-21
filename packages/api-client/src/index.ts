// Shared API client for all micro-apps (<50 lines)
const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3100';

// Auth token management  
let authToken: string | null = null;

// Check if we're in production (server deployment)
const isProduction = typeof window !== 'undefined' && window.location.hostname !== 'localhost';

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