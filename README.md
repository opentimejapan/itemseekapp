# ItemSeek Modular App

A micro-app architecture for comprehensive inventory management including:
- Buying/selling inventory
- Equipment maintenance tracking
- Dry cleaning services
- Linen laundry management
- Housekeeping/room status

## Architecture

Each micro-app is **<100 lines of code** and handles a specific domain.

### Apps
- `inventory-app` - Traditional inventory (buy/sell/stock)
- `maintenance-app` - Equipment maintenance schedules
- `laundry-app` - Linen and dry cleaning management
- `housekeeping-app` - Room cleaning status
- `api-gateway` - Shared API with tRPC

### Packages
- `@itemseek/db` - Shared database (Drizzle + PostgreSQL)
- `@itemseek/ui` - Shared UI components (Tailwind)
- `@itemseek/auth` - Authentication wrapper (Clerk)
- `@itemseek/api-contracts` - Shared TypeScript/Zod contracts

## Getting Started

```bash
pnpm install
pnpm dev
```

## Deploy

Each app deploys independently to Vercel.