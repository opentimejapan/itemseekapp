#!/bin/bash

SERVER_IP="172.104.117.4"
SERVER_USER="root"

echo "🔧 Applying quick fix to server..."

# Create and run fix script on server
ssh $SERVER_USER@$SERVER_IP << 'EOF'
cd /var/www/itemseekapp

echo "📥 Pulling latest changes..."
git pull origin main

echo "📦 Cleaning and reinstalling..."
rm -rf node_modules packages/*/node_modules apps/*/node_modules
rm -rf packages/*/dist apps/*/.next

echo "📦 Installing with pnpm..."
pnpm install --shamefully-hoist

echo "🔨 Building packages..."
cd packages/api-client && pnpm build && cd ../..

echo "🔨 Building all apps..."
pnpm build

echo "🚀 Restarting services..."
pm2 restart all

echo "✅ Fix applied!"
pm2 status
EOF

echo "✅ Fix deployment complete!"