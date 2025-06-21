'use client';
import { useState } from 'react';
import { login } from '@itemseek/api-client';

export default function LoginPage() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      await login(formData.email, formData.password);
      // Redirect to inventory app
      window.location.href = '/inventory';
    } catch (err: any) {
      setError(err.message || 'Invalid email or password');
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-xl p-8 w-full max-w-md">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Welcome Back</h1>
          <p className="text-gray-600">Sign in to manage your inventory</p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded-lg text-sm">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Email Address
            </label>
            <input
              type="email"
              required
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
              placeholder="you@example.com"
              value={formData.email}
              onChange={(e) => setFormData({...formData, email: e.target.value})}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Password
            </label>
            <input
              type="password"
              required
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
              placeholder="Enter your password"
              value={formData.password}
              onChange={(e) => setFormData({...formData, password: e.target.value})}
            />
          </div>

          <div className="flex items-center justify-between">
            <label className="flex items-center">
              <input type="checkbox" className="mr-2" />
              <span className="text-sm text-gray-600">Remember me</span>
            </label>
            <a href="#" className="text-sm text-blue-600 hover:text-blue-700">
              Forgot password?
            </a>
          </div>

          <div className="space-y-4">
            <button
              type="submit"
              disabled={loading}
              className="w-full bg-blue-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-blue-700 transition duration-200 transform hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none"
            >
              {loading ? 'Signing In...' : 'Sign In'}
            </button>

            <div className="text-center text-sm text-gray-600">
              Don't have an account?{' '}
              <a href="/signup" className="text-blue-600 hover:text-blue-700 font-medium">
                Create one
              </a>
            </div>
          </div>
        </form>

        <div className="mt-8">
          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-gray-300"></div>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-4 bg-white text-gray-500">Demo Account</span>
            </div>
          </div>

          <div className="mt-4 p-4 bg-gray-50 rounded-lg">
            <p className="text-sm text-gray-600 text-center">
              <strong>Email:</strong> demo@itemseek.com<br />
              <strong>Password:</strong> demo123
            </p>
            <button
              type="button"
              onClick={() => {
                setFormData({ email: 'demo@itemseek.com', password: 'demo123' });
              }}
              className="mt-2 w-full text-sm text-blue-600 hover:text-blue-700 font-medium"
            >
              Fill Demo Credentials
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}