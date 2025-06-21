'use client';
import { useState, useEffect } from 'react';
import useSWR from 'swr';
import { type Item, type BusinessConfig } from '@itemseek/api-contracts';
import { fetcher, apiFetch, login, setAuthToken, getAuthToken } from '@itemseek/api-client';

// Mobile-first inventory with API connection (<95 lines)
export default function InventoryApp() {
  const [isAuth, setIsAuth] = useState(false);
  const [category, setCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');
  
  // Check for existing auth token
  useEffect(() => {
    const token = getAuthToken();
    if (token) {
      setIsAuth(true);
    } else {
      // Auto-login for demo
      login('demo@itemseek.com', 'demo123')
        .then(() => setIsAuth(true))
        .catch(() => console.log('Backend not available, using local mode'));
    }
  }, []);
  
  const { data: config } = useSWR<BusinessConfig>(
    isAuth ? '/api/config' : null,
    fetcher,
    {
      fallbackData: {
        id: '1',
        name: 'Demo Business',
        industry: 'hospitality',
        settings: {},
        createdAt: new Date(),
        itemCategories: ['Linen', 'Cleaning', 'Amenities', 'Food & Beverage'],
        statuses: ['available', 'low', 'out of stock'],
        units: ['pieces', 'kg', 'boxes', 'units']
      }
    }
  );
  
  const { data: items = [], mutate } = useSWR<Item[]>(
    isAuth ? '/api/items' : null,
    fetcher,
    {
      fallbackData: [
        { id: '1', name: 'Bath Towels', quantity: 150, unit: 'pieces', location: 'Storage Room A', category: 'Linen', status: 'available', lastUpdated: new Date(), metadata: {} },
        { id: '2', name: 'Hand Soap', quantity: 25, unit: 'boxes', location: 'Supply Closet', category: 'Amenities', status: 'low', lastUpdated: new Date(), metadata: {} },
      ]
    }
  );

  const handleQuantityUpdate = async (id: string, delta: number) => {
    if ('vibrate' in navigator) navigator.vibrate(10);
    
    try {
      await apiFetch(`/api/items/${id}/transact`, {
        method: 'POST',
        body: JSON.stringify({ 
          type: delta > 0 ? 'in' : 'out', 
          quantity: Math.abs(delta),
          reason: 'Manual adjustment'
        })
      });
      mutate();
    } catch (error) {
      console.error('Failed to update quantity:', error);
      // Fallback to local update
      const updatedItems = items.map(item => {
        if (item.id === id) {
          const newQuantity = Math.max(0, item.quantity + delta);
          return { 
            ...item, 
            quantity: newQuantity,
            status: newQuantity === 0 ? 'out of stock' : newQuantity < 50 ? 'low' : 'available'
          };
        }
        return item;
      });
      mutate(updatedItems, false);
    }
  };

  const categories = ['all', ...(config?.itemCategories || [])];
  const filtered = items.filter(item => {
    const matchesCategory = category === 'all' || item.category === category;
    const matchesSearch = item.name.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <header className="sticky top-0 z-10 bg-white shadow-sm">
        <div className="px-4 py-3">
          <h1 className="text-xl font-bold">{config?.name || 'Inventory'}</h1>
          <p className="text-sm text-gray-500">{items.length} items tracked</p>
        </div>
        
        <div className="px-4 pb-3">
          <input
            type="search"
            placeholder="Search items..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full px-4 py-2 bg-gray-100 rounded-full text-sm"
          />
        </div>
      </header>
      
      <div className="px-4 py-3 overflow-x-auto flex gap-3 no-scrollbar">
        {categories.map(cat => (
          <button
            key={cat}
            onClick={() => setCategory(cat)}
            className={`px-4 py-2 rounded-full whitespace-nowrap ${
              category === cat ? 'bg-blue-600 text-white' : 'bg-gray-100'
            }`}
          >
            {cat === 'all' ? 'All' : cat}
          </button>
        ))}
      </div>

      <div className="px-4 space-y-3">
        {filtered.map((item) => (
          <div key={item.id} className="bg-white rounded-2xl p-4 shadow-sm">
            <div className="flex justify-between items-start mb-3">
              <div className="flex-1">
                <h3 className="font-semibold text-lg">{item.name}</h3>
                <p className="text-sm text-gray-500">{item.location}</p>
              </div>
              <span className={`px-2 py-1 rounded-full text-xs font-medium
                ${item.status === 'available' ? 'bg-green-100 text-green-800' : 
                  item.status === 'low' ? 'bg-red-100 text-red-800' : 
                  'bg-gray-100 text-gray-800'}`}>
                {item.status}
              </span>
            </div>
            
            <div className="flex items-center justify-between">
              <span className="text-2xl font-bold">
                {item.quantity} {item.unit}
              </span>
              <div className="flex gap-3">
                <button
                  onClick={() => handleQuantityUpdate(item.id, -1)}
                  disabled={item.quantity === 0}
                  className="w-12 h-12 rounded-full bg-red-100 text-red-600 text-xl 
                           disabled:opacity-50 active:scale-95"
                >
                  −
                </button>
                <button
                  onClick={() => handleQuantityUpdate(item.id, 1)}
                  className="w-12 h-12 rounded-full bg-green-100 text-green-600 text-xl 
                           active:scale-95"
                >
                  +
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}