#!/bin/bash

echo "🔧 Permanent Fix for api-client Build Issue"
echo "=========================================="

cd /var/www/itemseekapp || cd /data/projects/itemseekapp || exit 1

echo "📦 Step 1: Installing build tools for api-client..."
cd packages/api-client

# Ensure we have all necessary build dependencies
pnpm add -D tsup typescript @types/node

echo ""
echo "🔨 Step 2: Building api-client..."
pnpm build

echo ""
echo "✅ Step 3: Verifying build output..."
if [ -d "dist" ]; then
    echo "SUCCESS! dist folder created:"
    ls -la dist/
else
    echo "❌ Build failed - checking why..."
    echo "Package.json content:"
    cat package.json
    echo ""
    echo "Trying alternate build method..."
    npx tsup src/index.ts --format cjs,esm --dts --clean
fi

echo ""
echo "📦 Step 4: Reinstalling all dependencies..."
cd ../..
pnpm install --shamefully-hoist

echo ""
echo "🔨 Step 5: Building all apps..."
pnpm build

echo ""
echo "🚀 Step 6: Restarting services..."
pm2 restart all

echo ""
echo "✅ Permanent fix applied!"
echo ""
echo "📊 Final verification:"
ls -la packages/api-client/dist/ 2>/dev/null || echo "❌ dist still missing"
pm2 status