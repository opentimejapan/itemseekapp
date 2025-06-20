#!/bin/bash

echo "🚀 Starting ItemSeek Development Environment"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to open new terminal tab (macOS)
open_new_tab() {
    osascript -e "tell application \"Terminal\" to do script \"cd $PWD && $1\""
}

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    pnpm install
fi

# Setup database if needed
if [ ! -f "apps/itemseek-backend/.env" ]; then
    echo "Setting up database..."
    ./setup-db.sh
fi

echo -e "\n${BLUE}Starting services...${NC}\n"

# Start backend
echo "1. Starting backend (port 3100)..."
open_new_tab "cd apps/itemseek-backend && pnpm dev"

# Wait for backend to start
sleep 3

# Start micro-apps
echo "2. Starting inventory app (port 3001)..."
open_new_tab "cd apps/inventory-app && pnpm dev"

echo "3. Starting tasks app (port 3002)..."
open_new_tab "cd apps/tasks-app && pnpm dev"

echo "4. Starting locations app (port 3003)..."
open_new_tab "cd apps/locations-app && pnpm dev"

echo -e "\n${GREEN}✓ All services starting!${NC}\n"
echo "Services will be available at:"
echo "  - Backend API: http://localhost:3100"
echo "  - Inventory: http://localhost:3001"
echo "  - Tasks: http://localhost:3002"
echo "  - Locations: http://localhost:3003"
echo ""
echo "Press Ctrl+C to stop this script (services will continue running)"