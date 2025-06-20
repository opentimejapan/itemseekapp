import { pgTable, text, integer, timestamp, boolean, pgEnum } from 'drizzle-orm/pg-core';

export const categoryEnum = pgEnum('category', ['inventory', 'linen', 'equipment', 'supplies']);
export const itemStatusEnum = pgEnum('item_status', ['available', 'in-use', 'maintenance', 'dirty', 'clean']);
export const roomStatusEnum = pgEnum('room_status', ['clean', 'dirty', 'occupied', 'maintenance']);
export const laundryStatusEnum = pgEnum('laundry_status', ['dirty', 'washing', 'drying', 'clean', 'delivered']);
export const priorityEnum = pgEnum('priority', ['normal', 'rush', 'express']);

export const items = pgTable('items', {
  id: text('id').primaryKey(),
  name: text('name').notNull(),
  quantity: integer('quantity').notNull().default(0),
  location: text('location').notNull(),
  category: categoryEnum('category').notNull(),
  status: itemStatusEnum('status').notNull(),
  lastUpdated: timestamp('last_updated').notNull().defaultNow()
});

export const rooms = pgTable('rooms', {
  id: text('id').primaryKey(),
  number: text('number').notNull().unique(),
  status: roomStatusEnum('status').notNull().default('clean'),
  lastCleaned: timestamp('last_cleaned')
});

export const laundryItems = pgTable('laundry_items', {
  id: text('id').primaryKey(),
  type: text('type').notNull(),
  roomId: text('room_id').references(() => rooms.id),
  status: laundryStatusEnum('status').notNull(),
  weight: integer('weight'),
  priority: priorityEnum('priority').notNull().default('normal'),
  createdAt: timestamp('created_at').notNull().defaultNow()
});

export const maintenanceTasks = pgTable('maintenance_tasks', {
  id: text('id').primaryKey(),
  equipmentId: text('equipment_id').references(() => items.id),
  description: text('description').notNull(),
  dueDate: timestamp('due_date').notNull(),
  completed: boolean('completed').notNull().default(false),
  technician: text('technician'),
  completedAt: timestamp('completed_at')
});