# ItemSeek Frontend Apps

Modular micro-app architecture for universal inventory management. Works with any industry - hotels, restaurants, healthcare, retail, manufacturing, and more.

## Architecture

This repository contains the frontend micro-apps. The backend API is in a separate repository: [itemseekapp-backend](https://github.com/opentimejapan/itemseekapp-backend)

### Frontend Apps (This Repo)
- `inventory-app` - Track any items (products, supplies, ingredients)
- `tasks-app` - Manage any tasks (cleaning, maintenance, delivery)
- `locations-app` - Manage any spaces (rooms, warehouses, zones)

Each app is **<100 lines of code** for maximum maintainability.

### Shared Packages
- `@itemseek/ui` - Shared UI components (Tailwind)
- `@itemseek/api-client` - API client for backend
- `@itemseek/api-contracts` - Shared TypeScript/Zod contracts

## Quick Start

### 1. Clone Both Repositories

```bash
# Frontend (this repo)
git clone https://github.com/opentimejapan/itemseekapp.git
cd itemseekapp

# Backend (separate terminal)
git clone https://github.com/opentimejapan/itemseekapp-backend.git
cd itemseekapp-backend
```

### 2. Setup Backend First

Follow the [backend setup guide](https://github.com/opentimejapan/itemseekapp-backend) to:
1. Install PostgreSQL
2. Configure environment
3. Run migrations
4. Start the API server

### 3. Setup Frontend

```bash
# Install dependencies
pnpm install

# Start all apps
pnpm dev
```

### 4. Access Apps

- **Inventory**: http://localhost:3001
- **Tasks**: http://localhost:3002
- **Locations**: http://localhost:3003

## Mobile-First Design

All apps are designed for mobile devices first:
- Large touch targets (48px minimum)
- Thumb-friendly navigation
- Swipe gestures (coming soon)
- Offline support (coming soon)

## Industry Configuration

The system adapts to your industry automatically based on backend configuration:

- **Hotels**: Rooms, linens, amenities
- **Restaurants**: Ingredients, tables, equipment
- **Healthcare**: Medical supplies, beds, equipment
- **Retail**: Products, shelves, warehouses
- **Manufacturing**: Parts, tools, workstations

## Deployment

Each app can be deployed independently to Vercel, Netlify, or any static hosting.

```bash
cd apps/inventory-app
pnpm build
# Deploy the .next folder
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

## License

MIT