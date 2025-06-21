export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Hero Section */}
      <div className="container mx-auto px-4 py-16">
        <nav className="flex justify-between items-center mb-16">
          <h1 className="text-2xl font-bold text-gray-900">ItemSeek</h1>
          <div className="flex gap-4">
            <a href="/login" className="px-4 py-2 text-gray-700 hover:text-gray-900 transition">
              Sign In
            </a>
            <a href="/signup" className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition">
              Get Started
            </a>
          </div>
        </nav>

        <div className="text-center max-w-4xl mx-auto">
          <h2 className="text-5xl font-bold text-gray-900 mb-6">
            Universal Inventory Management<br />
            <span className="text-blue-600">For Any Business</span>
          </h2>
          <p className="text-xl text-gray-600 mb-8">
            From hotels to hospitals, restaurants to retail. One platform that adapts to your industry.
          </p>
          <div className="flex gap-4 justify-center">
            <a href="/signup" className="px-8 py-4 bg-blue-600 text-white rounded-lg text-lg font-medium hover:bg-blue-700 transition transform hover:scale-105">
              Start Free Trial
            </a>
            <a href="#features" className="px-8 py-4 border-2 border-gray-300 rounded-lg text-lg font-medium hover:border-gray-400 transition">
              Learn More
            </a>
          </div>
        </div>
      </div>

      {/* Features Grid */}
      <div id="features" className="container mx-auto px-4 py-16">
        <h3 className="text-3xl font-bold text-center mb-12">Micro-Apps for Every Need</h3>
        <div className="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
          <div className="bg-white rounded-2xl p-8 shadow-lg hover:shadow-xl transition">
            <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mb-4">
              <span className="text-2xl">📦</span>
            </div>
            <h4 className="text-xl font-bold mb-2">Inventory Management</h4>
            <p className="text-gray-600 mb-4">
              Track stock levels, manage supplies, and automate reordering for any type of inventory.
            </p>
            <a href="/signup" className="text-blue-600 font-medium hover:text-blue-700">
              Get Started →
            </a>
          </div>

          <div className="bg-white rounded-2xl p-8 shadow-lg hover:shadow-xl transition">
            <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mb-4">
              <span className="text-2xl">✓</span>
            </div>
            <h4 className="text-xl font-bold mb-2">Task Management</h4>
            <p className="text-gray-600 mb-4">
              Assign tasks, track progress, and ensure nothing falls through the cracks.
            </p>
            <a href="/signup" className="text-blue-600 font-medium hover:text-blue-700">
              Get Started →
            </a>
          </div>

          <div className="bg-white rounded-2xl p-8 shadow-lg hover:shadow-xl transition">
            <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mb-4">
              <span className="text-2xl">📍</span>
            </div>
            <h4 className="text-xl font-bold mb-2">Location Tracking</h4>
            <p className="text-gray-600 mb-4">
              Monitor rooms, zones, or any physical spaces with real-time status updates.
            </p>
            <a href="/signup" className="text-blue-600 font-medium hover:text-blue-700">
              Get Started →
            </a>
          </div>
        </div>
      </div>

      {/* Industries */}
      <div className="container mx-auto px-4 py-16">
        <h3 className="text-3xl font-bold text-center mb-12">Built for Your Industry</h3>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 max-w-4xl mx-auto">
          {['Hotels', 'Restaurants', 'Healthcare', 'Retail', 'Manufacturing', 'More'].map(industry => (
            <div key={industry} className="bg-white rounded-lg p-4 text-center shadow hover:shadow-lg transition">
              <p className="font-medium text-gray-700">{industry}</p>
            </div>
          ))}
        </div>
      </div>

      {/* CTA */}
      <div className="container mx-auto px-4 py-16 text-center">
        <div className="bg-blue-600 rounded-2xl p-12 max-w-3xl mx-auto">
          <h3 className="text-3xl font-bold text-white mb-4">
            Ready to Streamline Your Operations?
          </h3>
          <p className="text-blue-100 mb-8 text-lg">
            Join thousands of businesses already using ItemSeek
          </p>
          <a href="/signup" className="inline-block px-8 py-4 bg-white text-blue-600 rounded-lg text-lg font-medium hover:bg-gray-100 transition transform hover:scale-105">
            Start Your Free Trial
          </a>
        </div>
      </div>
    </div>
  );
}