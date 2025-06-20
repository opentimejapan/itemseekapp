'use client';
import { useState } from 'react';
import useSWR from 'swr';
import { type Room } from '@itemseek/api-contracts';

// Mobile-first room cleaning status (<85 lines)
export default function HousekeepingApp() {
  const [floor, setFloor] = useState<string>('all');
  const { data: rooms, mutate } = useSWR<Room[]>('/api/rooms');

  const updateRoomStatus = async (id: string, status: string) => {
    if ('vibrate' in navigator) navigator.vibrate(20);
    await fetch(`/api/rooms/${id}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status, lastCleaned: status === 'clean' ? new Date() : undefined })
    });
    mutate();
  };

  const floors = ['all', '1', '2', '3', '4'];
  const filtered = rooms?.filter(room => 
    floor === 'all' || room.number.startsWith(floor)
  );

  const statusColors = {
    clean: 'bg-green-500',
    dirty: 'bg-red-500',
    occupied: 'bg-blue-500',
    maintenance: 'bg-yellow-500'
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="sticky top-0 z-10 bg-white shadow-sm px-4 py-3">
        <h1 className="text-xl font-bold">Housekeeping</h1>
        <div className="flex gap-2 text-sm mt-1">
          <span className="text-green-600">
            {rooms?.filter(r => r.status === 'clean').length || 0} clean
          </span>
          <span className="text-red-600">
            {rooms?.filter(r => r.status === 'dirty').length || 0} dirty
          </span>
        </div>
      </header>

      {/* Floor filter */}
      <div className="px-4 py-3 overflow-x-auto flex gap-3 no-scrollbar">
        {floors.map(f => (
          <button
            key={f}
            onClick={() => setFloor(f)}
            className={`px-4 py-2 rounded-full ${
              floor === f ? 'bg-blue-600 text-white' : 'bg-gray-100'
            }`}
          >
            {f === 'all' ? 'All Floors' : `Floor ${f}`}
          </button>
        ))}
      </div>

      {/* Room grid - optimized for thumb reach */}
      <div className="px-4 pb-6 grid grid-cols-3 gap-3">
        {filtered?.map((room) => (
          <button
            key={room.id}
            onClick={() => updateRoomStatus(
              room.id, 
              room.status === 'clean' ? 'dirty' : 'clean'
            )}
            className={`aspect-square rounded-2xl flex flex-col items-center justify-center
                      text-white font-bold text-xl active:scale-95 transition-all
                      ${statusColors[room.status]}`}
          >
            <span className="text-3xl">{room.number}</span>
            <span className="text-xs mt-1 opacity-90">
              {room.status}
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}