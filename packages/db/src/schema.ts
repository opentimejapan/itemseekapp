import { pgTable, text, integer, timestamp, boolean, jsonb, uuid } from 'drizzle-orm/pg-core';

// Organizations for multi-tenancy
export const organizations = pgTable('organizations', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: text('name').notNull(),
  industry: text('industry').notNull(),
  config: jsonb('config').notNull(), // Stores BusinessConfig
  createdAt: timestamp('created_at').notNull().defaultNow()
});

// Items - universal inventory
export const items = pgTable('items', {
  id: uuid('id').primaryKey().defaultRandom(),
  organizationId: uuid('organization_id').notNull().references(() => organizations.id),
  name: text('name').notNull(),
  quantity: integer('quantity').notNull().default(0),
  unit: text('unit').notNull(),
  location: text('location').notNull(),
  category: text('category').notNull(),
  status: text('status').notNull(),
  metadata: jsonb('metadata').default({}),
  lastUpdated: timestamp('last_updated').notNull().defaultNow()
});

// Locations - rooms, warehouses, zones, etc.
export const locations = pgTable('locations', {
  id: uuid('id').primaryKey().defaultRandom(),
  organizationId: uuid('organization_id').notNull().references(() => organizations.id),
  name: text('name').notNull(),
  type: text('type').notNull(),
  status: text('status').notNull(),
  parentId: uuid('parent_id').references(() => locations.id),
  metadata: jsonb('metadata').default({}),
  createdAt: timestamp('created_at').notNull().defaultNow()
});

// Tasks - cleaning, maintenance, delivery, etc.
export const tasks = pgTable('tasks', {
  id: uuid('id').primaryKey().defaultRandom(),
  organizationId: uuid('organization_id').notNull().references(() => organizations.id),
  type: text('type').notNull(),
  targetId: uuid('target_id').notNull(),
  targetType: text('target_type').notNull(), // 'item' or 'location'
  status: text('status').notNull(),
  priority: text('priority').notNull(),
  assignee: text('assignee'),
  dueDate: timestamp('due_date'),
  completedAt: timestamp('completed_at'),
  metadata: jsonb('metadata').default({}),
  createdAt: timestamp('created_at').notNull().defaultNow()
});

// Transactions - track all inventory movements
export const transactions = pgTable('transactions', {
  id: uuid('id').primaryKey().defaultRandom(),
  organizationId: uuid('organization_id').notNull().references(() => organizations.id),
  type: text('type').notNull(), // in, out, transfer, adjust, consume, produce
  itemId: uuid('item_id').notNull().references(() => items.id),
  quantity: integer('quantity').notNull(),
  fromLocation: text('from_location'),
  toLocation: text('to_location'),
  reason: text('reason').notNull(),
  userId: text('user_id').notNull(),
  metadata: jsonb('metadata').default({}),
  timestamp: timestamp('timestamp').notNull().defaultNow()
});

// Users - simple user management
export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  organizationId: uuid('organization_id').notNull().references(() => organizations.id),
  email: text('email').notNull().unique(),
  name: text('name'),
  role: text('role').notNull().default('user'),
  metadata: jsonb('metadata').default({}),
  createdAt: timestamp('created_at').notNull().defaultNow()
});