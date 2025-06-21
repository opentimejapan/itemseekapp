#!/bin/bash

echo "🔧 Fixing ItemSeek on server..."
echo "================================"

ssh root@172.104.117.4 << 'EOF'
echo "📂 Navigating to project..."
cd /var/www/itemseekapp

echo "📥 Pulling latest changes..."
git pull origin main

echo "🧹 Cleaning old builds..."
rm -rf node_modules packages/*/node_modules apps/*/node_modules
rm -rf packages/*/dist apps/*/.next

echo "📦 Installing dependencies..."
pnpm install --shamefully-hoist

echo "🔨 Building api-client package..."
cd packages/api-client
pnpm build
cd ../..

echo "🔨 Building all apps..."
pnpm build

echo "🚀 Restarting services..."
pm2 restart all

echo "📊 Current status:"
pm2 status

echo "✅ Fix complete!"
EOF