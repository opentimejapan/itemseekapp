# ItemSeek Backend

Custom Node.js + PostgreSQL backend for the ItemSeek inventory management system.

## Features

- 🔐 JWT Authentication
- 🏢 Multi-tenant support
- 🔄 RESTful API
- 📊 PostgreSQL with Drizzle ORM
- 🚀 Industry-agnostic design
- 📱 Mobile-optimized responses

## Setup

### 1. Install PostgreSQL

```bash
# macOS
brew install postgresql
brew services start postgresql

# Ubuntu/Debian
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql

# Create database
createdb itemseek
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your database credentials
```

### 3. Install Dependencies

```bash
pnpm install
```

### 4. Run Migrations

```bash
pnpm db:generate  # Generate migration files
pnpm db:migrate   # Apply migrations
pnpm db:studio    # Open Drizzle Studio (optional)
```

### 5. Start Server

```bash
pnpm dev          # Development mode
pnpm build        # Build for production
pnpm start        # Production mode
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - Login with email/password
- `GET /api/auth/verify` - Verify JWT token

### Business Config
- `GET /api/config` - Get industry-specific configuration

### Items
- `GET /api/items` - List items (with filters)
- `POST /api/items` - Create new item
- `POST /api/items/:id/transact` - Update quantity

### Locations
- `GET /api/locations` - List locations
- `POST /api/locations` - Create location
- `PATCH /api/locations/:id` - Update status

### Tasks
- `GET /api/tasks` - List tasks
- `POST /api/tasks` - Create task
- `PATCH /api/tasks/:id` - Update task

## Environment Variables

- `DATABASE_URL` - PostgreSQL connection string
- `PORT` - Server port (default: 3100)
- `JWT_SECRET` - Secret for JWT tokens
- `INDUSTRY` - Business type (hotel, restaurant, etc.)

## Multi-Tenancy

Each organization has its own:
- Items, locations, and tasks
- Custom categories and statuses
- Users and permissions

## Security

- JWT authentication required for all endpoints
- Organization-level data isolation
- Input validation with Zod
- SQL injection protection via Drizzle ORM