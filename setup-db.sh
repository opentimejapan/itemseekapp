#!/bin/bash

echo "🚀 ItemSeek Database Setup"
echo "========================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo -e "${RED}PostgreSQL is not installed!${NC}"
    echo "Install with: brew install postgresql"
    exit 1
fi

# Try to start PostgreSQL if not running
echo "Checking PostgreSQL status..."
if ! pg_isready -q; then
    echo "Starting PostgreSQL..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        brew services start postgresql@16 2>/dev/null || \
        pg_ctl -D /opt/homebrew/var/postgresql@16 start 2>/dev/null || \
        pg_ctl -D /usr/local/var/postgres start 2>/dev/null || \
        echo "Please start PostgreSQL manually"
    else
        # Linux
        sudo systemctl start postgresql 2>/dev/null || \
        sudo service postgresql start 2>/dev/null || \
        echo "Please start PostgreSQL manually"
    fi
    
    sleep 2
fi

# Create database
echo "Creating itemseek database..."
createdb itemseek 2>/dev/null && echo -e "${GREEN}✓ Database created${NC}" || echo "Database already exists"

# Create .env file if it doesn't exist
if [ ! -f apps/itemseek-backend/.env ]; then
    echo "Creating .env file..."
    cp apps/itemseek-backend/.env.example apps/itemseek-backend/.env
    
    # Update DATABASE_URL with current user
    DB_USER=$(whoami)
    sed -i.bak "s|postgresql://user:password@localhost:5432/itemseek|postgresql://$DB_USER@localhost:5432/itemseek|" apps/itemseek-backend/.env
    rm apps/itemseek-backend/.env.bak
    
    echo -e "${GREEN}✓ Created .env file${NC}"
else
    echo ".env file already exists"
fi

echo ""
echo "Next steps:"
echo "1. cd apps/itemseek-backend"
echo "2. pnpm install"
echo "3. pnpm db:push    # Create tables"
echo "4. pnpm dev        # Start server"