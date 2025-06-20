'use client';
import { useState } from 'react';
import useSWR from 'swr';
import { StatusBadge } from '@itemseek/ui';
import { type LaundryItem } from '@itemseek/api-contracts';

// Mobile-first laundry management (<95 lines)
export default function LaundryApp() {
  const [filter, setFilter] = useState<string>('all');
  const { data: items, mutate } = useSWR<LaundryItem[]>('/api/laundry');

  const updateStatus = async (id: string, status: string) => {
    if ('vibrate' in navigator) navigator.vibrate(10);
    await fetch(`/api/laundry/${id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status })
    });
    mutate();
  };

  const statusFlow = {
    dirty: 'washing',
    washing: 'drying',
    drying: 'clean',
    clean: 'delivered'
  };

  const filters = ['all', 'dirty', 'washing', 'drying', 'clean'];
  const filtered = items?.filter(item => filter === 'all' || item.status === filter);

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <header className="sticky top-0 z-10 bg-white shadow-sm px-4 py-3">
        <h1 className="text-xl font-bold">Laundry Service</h1>
        <p className="text-sm text-gray-500">{items?.length || 0} items</p>
      </header>

      {/* Status filters - swipeable on mobile */}
      <div className="px-4 py-3 overflow-x-auto flex gap-3 no-scrollbar">
        {filters.map(f => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`px-4 py-2 rounded-full whitespace-nowrap ${
              filter === f ? 'bg-blue-600 text-white' : 'bg-gray-100'
            }`}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}
            {f !== 'all' && (
              <span className="ml-2 opacity-60">
                {items?.filter(i => i.status === f).length || 0}
              </span>
            )}
          </button>
        ))}
      </div>

      {/* Laundry items with swipe-like actions */}
      <div className="px-4 space-y-3">
        {filtered?.map((item) => (
          <div key={item.id} className="bg-white rounded-2xl overflow-hidden shadow-sm">
            <div className="p-4">
              <div className="flex justify-between items-start mb-3">
                <div>
                  <h3 className="font-semibold capitalize">{item.type}</h3>
                  {item.roomId && <p className="text-sm text-gray-500">Room {item.roomId}</p>}
                </div>
                <div className="text-right">
                  <StatusBadge status={item.status} />
                  <p className="text-xs text-gray-500 mt-1">{item.priority}</p>
                </div>
              </div>
              
              {item.weight && (
                <p className="text-sm text-gray-600 mb-3">{item.weight}kg</p>
              )}
            </div>

            {/* Large touch target for status progression */}
            {item.status !== 'delivered' && (
              <button
                onClick={() => updateStatus(item.id, statusFlow[item.status as keyof typeof statusFlow])}
                className="w-full py-4 bg-blue-50 text-blue-600 font-medium active:bg-blue-100"
              >
                Move to {statusFlow[item.status as keyof typeof statusFlow]}
              </button>
            )}
          </div>
        ))}
      </div>

      {/* Quick add button */}
      <button className="fixed bottom-6 right-6 w-14 h-14 bg-blue-600 text-white rounded-full 
                       shadow-lg flex items-center justify-center active:scale-95">
        <span className="text-2xl">+</span>
      </button>
    </div>
  );
}