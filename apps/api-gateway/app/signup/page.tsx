'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';

export default function SignupPage() {
  const router = useRouter();
  const [formData, setFormData] = useState({
    businessName: '',
    industry: 'hospitality',
    email: '',
    password: '',
  });

  const industries = [
    { value: 'hospitality', label: 'Hotels & Hospitality' },
    { value: 'restaurant', label: 'Restaurants & Food Service' },
    { value: 'healthcare', label: 'Healthcare & Medical' },
    { value: 'retail', label: 'Retail & E-commerce' },
    { value: 'manufacturing', label: 'Manufacturing' },
    { value: 'other', label: 'Other' }
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Demo: just redirect to inventory app
    alert('Demo: Account created! Redirecting to inventory app...');
    window.location.href = process.env.NODE_ENV === 'production' ? '/inventory' : 'http://localhost:3001';
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-xl p-8 w-full max-w-md">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Create Your Account</h1>
          <p className="text-gray-600">Start managing your inventory in minutes</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Business Name
            </label>
            <input
              type="text"
              required
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
              placeholder="Your Business Name"
              value={formData.businessName}
              onChange={(e) => setFormData({...formData, businessName: e.target.value})}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Industry
            </label>
            <select
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition"
              value={formData.industry}
              onChange={(e) => setFormData({...formData, industry: e.target.value})}
            >
              {industries.map(ind => (
                <option key={ind.value} value={ind.value}>{ind.label}</option>
              ))}
            </select>
          </div>

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
              placeholder="Create a strong password"
              value={formData.password}
              onChange={(e) => setFormData({...formData, password: e.target.value})}
            />
          </div>

          <div className="space-y-4">
            <button
              type="submit"
              className="w-full bg-blue-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-blue-700 transition duration-200 transform hover:scale-[1.02]"
            >
              Create Account
            </button>

            <div className="text-center text-sm text-gray-600">
              Already have an account?{' '}
              <a href="/login" className="text-blue-600 hover:text-blue-700 font-medium">
                Sign in
              </a>
            </div>
          </div>
        </form>

        <div className="mt-8 pt-6 border-t border-gray-200">
          <div className="text-xs text-center text-gray-500">
            By signing up, you agree to our Terms of Service and Privacy Policy
          </div>
        </div>
      </div>
    </div>
  );
}