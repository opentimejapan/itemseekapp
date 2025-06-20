# ItemSeek Modular Architecture (Industry-Agnostic)

## Overview

ItemSeek is a **universal inventory management system** built with micro-apps that adapt to ANY industry:
- 🏨 Hotels (linens, rooms, minibar)
- 🍕 Restaurants (ingredients, tables, equipment)
- 🏥 Healthcare (medical supplies, beds, equipment)
- 🏭 Manufacturing (parts, tools, workstations)
- 🛍️ Retail (products, shelves, warehouses)
- And ANY other business with inventory needs

## Core Principle: One System, Any Industry

Each micro-app is **generic by design** and configures itself based on the business type.

## Architecture Rules

1. **<100 Lines Per App**: Each micro-app must be under 100 lines of executable code
2. **Mobile-First**: Designed for thumb-friendly mobile use, scales to desktop
3. **Zero Configuration**: Apps auto-adapt based on business config
4. **Industry Agnostic**: No hardcoded business logic
5. **Offline-First**: Works without internet (coming soon)

## Micro-Apps

| App | Purpose | Adapts To |
|-----|---------|-----------|
| `inventory-app` | Track any items | Products, supplies, ingredients, parts |
| `tasks-app` | Manage any tasks | Cleaning, maintenance, delivery, inspection |
| `locations-app` | Manage any spaces | Rooms, warehouses, shelves, tables, zones |
| `transactions-app` | Track movement | Sales, transfers, consumption, production |
| `insights-app` | Analytics | Custom KPIs per industry |

## Shared Packages

| Package | Purpose |
|---------|---------|
| `@itemseek/db` | PostgreSQL + Drizzle ORM |
| `@itemseek/ui` | Tailwind components |
| `@itemseek/api-contracts` | Zod schemas |
| `@itemseek/api` | tRPC API gateway |

## How It Adapts

### Hotel Example
```json
{
  "industry": "hotel",
  "itemCategories": ["Linens", "Amenities", "Minibar", "Maintenance"],
  "locationTypes": ["Room", "Floor", "Storage"],
  "taskTypes": ["Cleaning", "Laundry", "Maintenance"],
  "units": ["pieces", "sets", "bottles"]
}
```

### Restaurant Example
```json
{
  "industry": "restaurant",
  "itemCategories": ["Ingredients", "Beverages", "Supplies", "Equipment"],
  "locationTypes": ["Kitchen", "Storage", "Dining Area", "Bar"],
  "taskTypes": ["Prep", "Cleaning", "Maintenance", "Delivery"],
  "units": ["kg", "liters", "pieces", "portions"]
}
```

## Mobile-First Design

- **Large Touch Targets**: 48px minimum
- **Thumb-Friendly**: Bottom navigation, reachable buttons
- **Gesture Support**: Swipe actions (coming soon)
- **Offline Mode**: PWA with service workers
- **Haptic Feedback**: Touch confirmation

## Deployment

Each app deploys independently:
```bash
apps/inventory-app → inventory.yourdomain.com
apps/tasks-app → tasks.yourdomain.com
apps/locations-app → locations.yourdomain.com
```

Or as routes in a single domain:
```
yourdomain.com/inventory
yourdomain.com/tasks
yourdomain.com/locations
```

## Tech Stack

- **Monorepo**: TurboRepo + pnpm
- **Frontend**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS
- **Data Fetching**: SWR
- **API**: tRPC
- **Database**: PostgreSQL (Supabase/Neon)
- **Type Safety**: TypeScript + Zod
- **Deployment**: Vercel

## Getting Started

```bash
# Install dependencies
pnpm install

# Start all apps
pnpm dev

# Start specific app
cd apps/inventory-app && pnpm dev
```

## Adding Your Industry

1. Create a business config with your categories, statuses, and units
2. Deploy the same apps - they'll adapt automatically
3. No code changes needed!

The beauty of ItemSeek: **One codebase, infinite industries.**