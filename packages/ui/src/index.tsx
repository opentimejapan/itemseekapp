import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Button component (<20 lines)
export function Button({ 
  children, 
  variant = 'primary', 
  onClick, 
  disabled = false 
}: {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'danger';
  onClick?: () => void;
  disabled?: boolean;
}) {
  const variants = {
    primary: 'bg-blue-600 hover:bg-blue-700 text-white',
    secondary: 'bg-gray-200 hover:bg-gray-300 text-gray-900',
    danger: 'bg-red-600 hover:bg-red-700 text-white'
  };
  
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={cn(
        'px-4 py-2 rounded-md font-medium transition-colors',
        variants[variant],
        disabled && 'opacity-50 cursor-not-allowed'
      )}
    >
      {children}
    </button>
  );
}

// Card component (<15 lines)
export function Card({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={cn('bg-white rounded-lg shadow-md p-4', className)}>
      {children}
    </div>
  );
}

// Status badge (<15 lines)
export function StatusBadge({ status }: { status: string }) {
  const colors: Record<string, string> = {
    clean: 'bg-green-100 text-green-800',
    dirty: 'bg-red-100 text-red-800',
    occupied: 'bg-blue-100 text-blue-800',
    maintenance: 'bg-yellow-100 text-yellow-800',
    available: 'bg-green-100 text-green-800'
  };
  
  return (
    <span className={cn(
      'px-2 py-1 rounded-full text-xs font-medium',
      colors[status] || 'bg-gray-100 text-gray-800'
    )}>
      {status}
    </span>
  );
}