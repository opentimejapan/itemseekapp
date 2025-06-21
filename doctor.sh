#!/bin/bash

echo "🩺 ItemSeek Doctor - Diagnostic Report"
echo "====================================="
echo ""

# Check if we're on the server or local
if [ -d "/var/www/itemseekapp" ]; then
    echo "📍 Running on: SERVER"
    cd /var/www/itemseekapp
else
    echo "📍 Running on: LOCAL"
    cd /Users/kyleburns/itemseekapp
fi

echo ""
echo "🔍 System Information:"
echo "----------------------"
echo "Current directory: $(pwd)"
echo "Node version: $(node --version 2>/dev/null || echo 'Node not found')"
echo "npm version: $(npm --version 2>/dev/null || echo 'npm not found')"
echo "pnpm version: $(pnpm --version 2>/dev/null || echo 'pnpm not found')"

echo ""
echo "📦 Package Structure:"
echo "--------------------"
if [ -f "package.json" ]; then
    echo "✅ Root package.json exists"
else
    echo "❌ Root package.json missing"
fi

echo ""
echo "Checking packages:"
for pkg in packages/*/; do
    if [ -d "$pkg" ]; then
        pkgname=$(basename "$pkg")
        echo -n "  $pkgname: "
        if [ -f "$pkg/package.json" ]; then
            echo -n "✅ package.json "
        else
            echo -n "❌ package.json "
        fi
        if [ -d "$pkg/dist" ] || [ -d "$pkg/.next" ]; then
            echo "✅ built"
        else
            echo "❌ not built"
        fi
    fi
done

echo ""
echo "Checking apps:"
for app in apps/*/; do
    if [ -d "$app" ]; then
        appname=$(basename "$app")
        echo -n "  $appname: "
        if [ -f "$app/package.json" ]; then
            echo -n "✅ package.json "
        else
            echo -n "❌ package.json "
        fi
        if [ -d "$app/.next" ]; then
            echo "✅ built"
        else
            echo "❌ not built"
        fi
    fi
done

echo ""
echo "🔧 Critical Files Check:"
echo "-----------------------"
# Check api-client specifically
if [ -f "packages/api-client/dist/index.js" ]; then
    echo "✅ api-client dist/index.js exists"
else
    echo "❌ api-client dist/index.js missing - THIS IS THE ISSUE!"
fi

if [ -f "packages/api-client/dist/index.d.ts" ]; then
    echo "✅ api-client dist/index.d.ts exists"
else
    echo "❌ api-client dist/index.d.ts missing"
fi

# Check if we're on server
if [ -d "/var/www/itemseekapp" ]; then
    echo ""
    echo "🚀 PM2 Status:"
    echo "--------------"
    pm2 status

    echo ""
    echo "🌐 Nginx Status:"
    echo "----------------"
    systemctl status nginx --no-pager | head -n 5

    echo ""
    echo "🐘 PostgreSQL Status:"
    echo "--------------------"
    systemctl status postgresql --no-pager | head -n 5

    echo ""
    echo "📊 Backend Status:"
    echo "-----------------"
    if [ -d "/var/www/itemseekapp-backend" ]; then
        echo "✅ Backend directory exists"
        cd /var/www/itemseekapp-backend
        if [ -f ".env" ]; then
            echo "✅ Backend .env exists"
        else
            echo "❌ Backend .env missing"
        fi
    else
        echo "❌ Backend directory missing"
    fi
fi

echo ""
echo "💊 Recommended Fix:"
echo "------------------"
if [ ! -f "packages/api-client/dist/index.js" ]; then
    echo "Run these commands to fix:"
    echo "1. cd packages/api-client"
    echo "2. pnpm build"
    echo "3. cd ../.."
    echo "4. pnpm build"
    echo "5. pm2 restart all"
else
    echo "API client is built. If you're still seeing errors:"
    echo "1. pm2 logs api-gateway"
    echo "2. Check for other error messages"
fi

echo ""
echo "✅ Diagnostic complete!"