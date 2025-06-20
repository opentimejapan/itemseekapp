#!/bin/bash

echo "🚀 Starting ItemSeek Frontend Apps"
echo "=================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Function to open new terminal tab (macOS)
open_new_tab() {
    osascript -e "tell application \"Terminal\" to do script \"cd $PWD && $1\""
}

# Check if backend is running
echo "Checking backend connection..."
if curl -s http://localhost:3100/health > /dev/null; then
    echo -e "${GREEN}✓ Backend is running${NC}"
else
    echo -e "${RED}✗ Backend is not running!${NC}"
    echo ""
    echo "Please start the backend first:"
    echo "1. cd ~/itemseekapp-backend"
    echo "2. npm install && npm run dev"
    echo ""
    exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    pnpm install
fi

echo -e "\n${BLUE}Starting frontend apps...${NC}\n"

# Start micro-apps
echo "1. Starting inventory app (port 3001)..."
open_new_tab "cd apps/inventory-app && pnpm dev"

echo "2. Starting tasks app (port 3002)..."
open_new_tab "cd apps/tasks-app && pnpm dev"

echo "3. Starting locations app (port 3003)..."
open_new_tab "cd apps/locations-app && pnpm dev"

echo -e "\n${GREEN}✓ All frontend apps starting!${NC}\n"
echo "Apps will be available at:"
echo "  - Inventory: http://localhost:3001"
echo "  - Tasks: http://localhost:3002"
echo "  - Locations: http://localhost:3003"
echo ""
echo "Backend API: http://localhost:3100"
echo ""
echo "Press Ctrl+C to stop this script (apps will continue running)"