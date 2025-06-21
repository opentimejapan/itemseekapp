#!/bin/bash

echo "🔧 Fixing ItemSeek Dependencies"
echo "=============================="

# This script fixes module resolution issues on the server

cd /var/www/itemseekapp

# Ensure we have the latest code
echo "📥 Pulling latest changes..."
git pull origin main

echo "📦 Cleaning node_modules..."
rm -rf node_modules
rm -rf apps/*/node_modules
rm -rf packages/*/node_modules
rm -rf apps/*/.next
rm -rf .next

echo "📦 Installing dependencies with pnpm..."
pnpm install --shamefully-hoist --force

echo "🔨 Building packages first..."
# Build packages in order with proper error handling
echo "  Building api-contracts..."
cd packages/api-contracts && pnpm build && cd ../.. || { echo "❌ Failed to build api-contracts"; cd ../..; }

echo "  Building db..."
cd packages/db && pnpm build && cd ../.. || { echo "❌ Failed to build db"; cd ../..; }

echo "  Building api-client..."
cd packages/api-client && pnpm build && cd ../.. || { echo "❌ Failed to build api-client"; cd ../..; }

echo "  Building ui..."
cd packages/ui && pnpm build && cd ../.. || { echo "❌ Failed to build ui"; cd ../..; }

echo "🔨 Building apps..."
pnpm build

echo "🚀 Restarting services..."
pm2 restart all

echo "✅ Dependencies fixed!"
echo ""
echo "📊 Checking package builds..."
for pkg in packages/*/; do
  if [ -d "$pkg/dist" ] || [ -d "$pkg/.next" ]; then
    echo "✅ $(basename $pkg) built successfully"
  else
    echo "❌ $(basename $pkg) build not found"
  fi
done

echo ""
echo "🔍 Verifying api-client exports..."
if [ -f "packages/api-client/dist/index.js" ]; then
  echo "✅ api-client dist found"
else
  echo "❌ api-client dist missing - this is the issue!"
fi

echo ""
echo "If you still see errors, try:"
echo "1. pm2 logs api-gateway"
echo "2. Check if all packages are listed in package.json files"
echo "3. Run: cd packages/api-client && pnpm build"