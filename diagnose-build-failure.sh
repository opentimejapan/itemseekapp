#!/bin/bash

echo "🔍 Diagnosing Build Failure Root Cause"
echo "====================================="

# This script identifies WHY the build is failing

cd /var/www/itemseekapp || cd /data/projects/itemseekapp || exit 1

echo ""
echo "1️⃣ Checking if api-client is built:"
echo "-----------------------------------"
if [ -d "packages/api-client/dist" ]; then
    echo "✅ dist folder exists"
    ls -la packages/api-client/dist/
else
    echo "❌ dist folder missing - THIS IS THE ROOT CAUSE"
fi

echo ""
echo "2️⃣ Checking package.json resolutions:"
echo "------------------------------------"
if [ -f "packages/api-client/package.json" ]; then
    echo "api-client package.json main field:"
    grep -E '"main":|"module":|"types":' packages/api-client/package.json
fi

echo ""
echo "3️⃣ Checking pnpm workspace links:"
echo "---------------------------------"
echo "Looking for symlinks in node_modules:"
ls -la node_modules/@itemseek/ 2>/dev/null || echo "❌ @itemseek not found in root node_modules"

echo ""
echo "4️⃣ Checking app dependencies:"
echo "-----------------------------"
for app in apps/*/package.json; do
    if [ -f "$app" ]; then
        appname=$(dirname "$app")
        echo -n "$(basename $appname): "
        grep -q "@itemseek/api-client" "$app" && echo "✅ has dependency" || echo "❌ missing dependency"
    fi
done

echo ""
echo "5️⃣ Checking Next.js transpilePackages:"
echo "-------------------------------------"
for config in apps/*/next.config.js; do
    if [ -f "$config" ]; then
        appname=$(dirname "$config")
        echo -n "$(basename $appname): "
        grep -q "@itemseek/api-client" "$config" && echo "✅ in transpilePackages" || echo "❌ NOT in transpilePackages"
    fi
done

echo ""
echo "6️⃣ Checking actual import errors:"
echo "--------------------------------"
echo "Running a test build of locations-app to see exact error:"
cd apps/locations-app
pnpm build 2>&1 | grep -A5 -B5 "Module not found" || echo "Build succeeded or different error"

echo ""
echo "🎯 ROOT CAUSE ANALYSIS:"
echo "----------------------"
if [ ! -d "../../packages/api-client/dist" ]; then
    echo "❌ The api-client package is not built (no dist folder)"
    echo "   Solution: Build api-client before building apps"
elif ! ls -la ../../node_modules/@itemseek/api-client 2>/dev/null | grep -q "packages/api-client"; then
    echo "❌ The api-client is not properly linked in node_modules"
    echo "   Solution: Run 'pnpm install' to create workspace links"
else
    echo "🤔 Need to check the exact webpack error"
fi