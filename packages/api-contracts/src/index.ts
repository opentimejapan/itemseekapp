import { z } from 'zod';

// Industry-agnostic schemas that adapt to any business type

// Generic item that can represent ANY inventory type
export const ItemSchema = z.object({
  id: z.string(),
  name: z.string(),
  quantity: z.number(),
  unit: z.string(), // pieces, kg, liters, boxes, etc.
  location: z.string(),
  category: z.string(), // Dynamic categories per industry
  status: z.string(), // Dynamic statuses per business
  metadata: z.record(z.any()), // Flexible fields for any industry
  lastUpdated: z.date()
});

// Generic space/location (room, warehouse, shelf, etc.)
export const LocationSchema = z.object({
  id: z.string(),
  name: z.string(),
  type: z.string(), // room, warehouse, shelf, zone, etc.
  status: z.string(), // available, occupied, maintenance, etc.
  parent: z.string().optional(), // For hierarchical locations
  metadata: z.record(z.any())
});

// Generic task (cleaning, maintenance, inspection, etc.)
export const TaskSchema = z.object({
  id: z.string(),
  type: z.string(), // cleaning, maintenance, inspection, delivery
  targetId: z.string(), // Item or location ID
  targetType: z.enum(['item', 'location']),
  status: z.string(), // pending, in-progress, completed
  priority: z.enum(['low', 'normal', 'high', 'urgent']),
  assignee: z.string().optional(),
  dueDate: z.date().optional(),
  metadata: z.record(z.any())
});

// Generic transaction (in/out/transfer/adjustment)
export const TransactionSchema = z.object({
  id: z.string(),
  type: z.enum(['in', 'out', 'transfer', 'adjust', 'consume', 'produce']),
  itemId: z.string(),
  quantity: z.number(),
  fromLocation: z.string().optional(),
  toLocation: z.string().optional(),
  reason: z.string(),
  metadata: z.record(z.any()),
  timestamp: z.date()
});

// Business configuration schema
export const BusinessConfigSchema = z.object({
  id: z.string(),
  name: z.string(),
  industry: z.string(), // hotel, restaurant, retail, healthcare, etc.
  itemCategories: z.array(z.string()),
  itemStatuses: z.array(z.string()),
  locationTypes: z.array(z.string()),
  taskTypes: z.array(z.string()),
  units: z.array(z.string()),
  customFields: z.record(z.object({
    type: z.enum(['text', 'number', 'date', 'boolean', 'select']),
    options: z.array(z.string()).optional()
  }))
});

export type Item = z.infer<typeof ItemSchema>;
export type Location = z.infer<typeof LocationSchema>;
export type Task = z.infer<typeof TaskSchema>;
export type Transaction = z.infer<typeof TransactionSchema>;
export type BusinessConfig = z.infer<typeof BusinessConfigSchema>;