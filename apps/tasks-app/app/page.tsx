'use client';
import { useState } from 'react';
import { type Task } from '@itemseek/api-contracts';

// Demo tasks data
const demoTasks: Task[] = [
  { id: '1', type: 'cleaning', targetId: 'Room 201', assignee: 'Maria', priority: 'high', status: 'pending', dueDate: new Date(Date.now() + 86400000), metadata: {} },
  { id: '2', type: 'maintenance', targetId: 'AC Unit 5', assignee: 'John', priority: 'urgent', status: 'in-progress', dueDate: new Date(), metadata: {} },
  { id: '3', type: 'delivery', targetId: 'Kitchen Supplies', assignee: 'Alex', priority: 'normal', status: 'pending', dueDate: new Date(Date.now() + 172800000), metadata: {} },
  { id: '4', type: 'cleaning', targetId: 'Lobby Area', assignee: 'Sarah', priority: 'low', status: 'completed', dueDate: new Date(Date.now() - 86400000), metadata: {} },
];

// Universal task management (<90 lines) - cleaning, maintenance, delivery, etc.
export default function TasksApp() {
  const [tasks, setTasks] = useState<Task[]>(demoTasks);
  const [filter, setFilter] = useState<string>('pending');

  const updateTaskStatus = (id: string, status: string) => {
    if ('vibrate' in navigator) navigator.vibrate(20);
    setTasks(tasks.map(task => 
      task.id === id ? { ...task, status } : task
    ));
  };

  const statuses = ['pending', 'in-progress', 'completed'];
  const filtered = tasks.filter(task => task.status === filter);
  
  const priorityColors = {
    low: 'bg-gray-100',
    normal: 'bg-blue-100',
    high: 'bg-orange-100',
    urgent: 'bg-red-100'
  };

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <header className="sticky top-0 z-10 bg-white shadow-sm px-4 py-3">
        <h1 className="text-xl font-bold">Tasks</h1>
        <p className="text-sm text-gray-500">
          {tasks.filter(t => t.status === 'pending').length} pending
        </p>
      </header>

      {/* Status filter tabs */}
      <div className="bg-white border-b sticky top-14 z-10">
        <div className="px-4 flex gap-6">
          {statuses.map(status => (
            <button
              key={status}
              onClick={() => setFilter(status)}
              className={`py-3 capitalize border-b-2 transition-colors ${
                filter === status 
                  ? 'text-blue-600 border-blue-600 font-medium' 
                  : 'text-gray-500 border-transparent'
              }`}
            >
              {status.replace('-', ' ')}
              <span className="ml-2 text-sm">
                ({tasks.filter(t => t.status === status).length})
              </span>
            </button>
          ))}
        </div>
      </div>

      {/* Task cards - adaptable to any task type */}
      <div className="px-4 py-4 space-y-3">
        {filtered.map((task) => (
          <div key={task.id} 
               className={`rounded-2xl overflow-hidden shadow-sm ${priorityColors[task.priority]}`}>
            <div className="p-4 bg-white bg-opacity-90">
              <div className="flex justify-between items-start mb-2">
                <div className="flex-1">
                  <p className="text-xs text-gray-500 uppercase">{task.type}</p>
                  <h3 className="font-semibold">{task.targetId}</h3>
                  {task.assignee && (
                    <p className="text-sm text-gray-600 mt-1">→ {task.assignee}</p>
                  )}
                </div>
                <span className="text-xs font-medium px-2 py-1 bg-white rounded-full">
                  {task.priority}
                </span>
              </div>
              
              {task.dueDate && (
                <p className="text-sm text-gray-600">
                  Due: {new Date(task.dueDate).toLocaleDateString()}
                </p>
              )}
            </div>
            
            {task.status !== 'completed' && (
              <button
                onClick={() => updateTaskStatus(
                  task.id, 
                  task.status === 'pending' ? 'in-progress' : 'completed'
                )}
                className="w-full py-3 bg-white bg-opacity-50 font-medium active:bg-opacity-70"
              >
                {task.status === 'pending' ? 'Start Task' : 'Complete Task'}
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}