#!/bin/bash

echo "🔧 Fixing ItemSeek Build Order"
echo "=============================="

# Ensure we're in the right directory
cd /var/www/itemseekapp || cd /data/projects/itemseekapp || exit 1

echo "📥 Pulling latest changes..."
git pull origin main

echo "🧹 Cleaning everything..."
rm -rf node_modules
rm -rf packages/*/node_modules
rm -rf packages/*/dist
rm -rf apps/*/node_modules
rm -rf apps/*/.next
rm -rf .next

echo "📦 Installing root dependencies..."
pnpm install --frozen-lockfile || pnpm install

echo "🔨 Building packages in correct order..."
echo "  1. Building api-contracts..."
cd packages/api-contracts
pnpm install
pnpm build || echo "No build script for api-contracts"
cd ../..

echo "  2. Building db..."
cd packages/db
pnpm install
pnpm build || echo "No build script for db"
cd ../..

echo "  3. Building api-client..."
cd packages/api-client
pnpm install
pnpm add -D tsup typescript @types/node
pnpm build
echo "  Verifying api-client build..."
ls -la dist/
cd ../..

echo "  4. Building ui..."
cd packages/ui
pnpm install
pnpm build || echo "No build script for ui"
cd ../..

echo "📦 Installing all dependencies again..."
pnpm install --shamefully-hoist

echo "🔨 Building apps..."
pnpm build --filter=api-gateway
pnpm build --filter=inventory-app
pnpm build --filter=tasks-app
pnpm build --filter=locations-app

echo "🚀 Restarting services..."
pm2 restart all

echo "✅ Build fix complete!"
pm2 status