'use client';
import { useState, useEffect } from 'react';
import useSWR from 'swr';
import { type Location, type BusinessConfig } from '@itemseek/api-contracts';
import { fetcher, apiFetch, getAuthToken } from '@itemseek/api-client';

// Universal location management (<85 lines) - rooms, warehouses, shelves, zones
export default function LocationsApp() {
  const [selectedType, setSelectedType] = useState<string>('all');
  const [isAuth, setIsAuth] = useState(false);
  
  useEffect(() => {
    if (getAuthToken()) setIsAuth(true);
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
        locationTypes: ['Room', 'Floor', 'Storage'],
        itemCategories: [],
        statuses: [],
        units: []
      }
    }
  );
  
  const { data: locations = [], mutate } = useSWR<Location[]>(
    isAuth ? '/api/locations' : null,
    fetcher,
    {
      fallbackData: [
        { id: '1', name: '101', type: 'Room', status: 'available', metadata: {} },
        { id: '2', name: '102', type: 'Room', status: 'occupied', metadata: {} },
      ]
    }
  );

  const updateLocationStatus = async (id: string, status: string) => {
    if ('vibrate' in navigator) navigator.vibrate(10);
    
    try {
      await apiFetch(`/api/locations/${id}`, {
        method: 'PATCH',
        body: JSON.stringify({ status })
      });
      mutate();
    } catch (error) {
      console.error('Failed to update location:', error);
      // Fallback to local update
      const updatedLocations = locations.map(loc => 
        loc.id === id ? { ...loc, status } : loc
      );
      mutate(updatedLocations, false);
    }
  };

  const types = ['all', ...(config?.locationTypes || [])];
  const filtered = locations.filter(
    loc => selectedType === 'all' || loc.type === selectedType
  );

  // Dynamic status colors based on business type
  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      available: 'bg-green-500',
      occupied: 'bg-blue-500',
      maintenance: 'bg-yellow-500',
      reserved: 'bg-purple-500',
      closed: 'bg-gray-500'
    };
    return colors[status] || 'bg-gray-400';
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="sticky top-0 z-10 bg-white shadow-sm px-4 py-3">
        <h1 className="text-xl font-bold">Locations</h1>
        <p className="text-sm text-gray-500">
          {locations.length} {config?.locationTypes?.[0] || 'locations'}
        </p>
      </header>

      {/* Location type filter */}
      <div className="px-4 py-3 overflow-x-auto flex gap-3 no-scrollbar">
        {types.map(type => (
          <button
            key={type}
            onClick={() => setSelectedType(type)}
            className={`px-4 py-2 rounded-full whitespace-nowrap ${
              selectedType === type ? 'bg-blue-600 text-white' : 'bg-gray-100'
            }`}
          >
            {type === 'all' ? 'All' : type}
          </button>
        ))}
      </div>

      {/* Location grid - visual status indicators */}
      <div className="px-4 pb-6 grid grid-cols-3 sm:grid-cols-4 gap-3">
        {filtered.map((location) => (
          <button
            key={location.id}
            onClick={() => {
              const nextStatus = location.status === 'available' ? 'occupied' : 'available';
              updateLocationStatus(location.id, nextStatus);
            }}
            className={`aspect-square rounded-2xl flex flex-col items-center justify-center
                      text-white font-bold active:scale-95 transition-all
                      ${getStatusColor(location.status)}`}
          >
            <span className="text-2xl">{location.name}</span>
            <span className="text-xs mt-1 opacity-90">
              {location.status}
            </span>
            {location.type !== config?.locationTypes?.[0] && (
              <span className="text-xs opacity-75">{location.type}</span>
            )}
          </button>
        ))}
      </div>
    </div>
  );
}