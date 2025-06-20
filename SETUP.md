# ItemSeek Setup Guide

## Prerequisites

- Node.js 18+ 
- PostgreSQL 14+
- pnpm (`npm install -g pnpm`)

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/opentimejapan/itemseekapp.git
cd itemseekapp

# 2. Install dependencies
pnpm install

# 3. Setup database
./setup-db.sh

# 4. Run migrations
cd apps/itemseek-backend
pnpm db:push

# 5. Seed demo data (optional)
pnpm db:seed

# 6. Start all services
cd ../..
./start.sh
```

## Manual Setup

### 1. PostgreSQL Setup

```bash
# macOS
brew install postgresql
brew services start postgresql

# Create database
createdb itemseek
```

### 2. Environment Configuration

```bash
cd apps/itemseek-backend
cp .env.example .env
# Edit .env with your database credentials
```

### 3. Database Setup

```bash
# Generate migrations
pnpm db:generate

# Apply migrations
pnpm db:push

# Seed demo data
pnpm db:seed

# Open database studio (optional)
pnpm db:studio
```

### 4. Start Services

Open separate terminals for each service:

```bash
# Terminal 1: Backend
cd apps/itemseek-backend
pnpm dev

# Terminal 2: Inventory App
cd apps/inventory-app
pnpm dev

# Terminal 3: Tasks App
cd apps/tasks-app
pnpm dev

# Terminal 4: Locations App
cd apps/locations-app
pnpm dev
```

## Access Points

- **Backend API**: http://localhost:3100
- **Inventory App**: http://localhost:3001
- **Tasks App**: http://localhost:3002
- **Locations App**: http://localhost:3003

## Demo Credentials

- Email: `demo@itemseek.com`
- Password: `demo123`

## Troubleshooting

### PostgreSQL Connection Issues

```bash
# Check if PostgreSQL is running
pg_isready

# Check connection
psql -d itemseek -c "SELECT 1"

# View logs
tail -f /opt/homebrew/var/postgresql@16/server.log
```

### Port Already in Use

```bash
# Find process using port
lsof -i :3100

# Kill process
kill -9 <PID>
```

### Database Reset

```bash
cd apps/itemseek-backend
dropdb itemseek
createdb itemseek
pnpm db:push
pnpm db:seed
```

## Development Tips

1. **Mobile Testing**: Use Chrome DevTools device mode
2. **API Testing**: Use Postman or curl
3. **Database Inspection**: Use `pnpm db:studio`
4. **Hot Reload**: All apps support hot reload

## Industry Configuration

Change the industry in `.env`:

```env
INDUSTRY=hotel     # Hotel management
INDUSTRY=restaurant # Restaurant inventory
INDUSTRY=healthcare # Medical supplies
INDUSTRY=retail    # Retail products
```

This automatically configures:
- Item categories
- Location types
- Task types
- Units of measurement