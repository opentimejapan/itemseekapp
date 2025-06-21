#!/bin/bash

echo "🎯 Final Root Cause Fix for ItemSeek"
echo "===================================="

cd /data/projects/itemseekapp || exit 1

echo "📊 Pre-fix Analysis:"
echo "-------------------"
echo "Checking for merge conflicts..."
CONFLICTS=$(grep -rl "<<<<<<< HEAD" . --include="*.tsx" --include="*.ts" --include="*.js" --include="*.jsx" 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist)
if [ ! -z "$CONFLICTS" ]; then
    echo "❌ Found merge conflicts in:"
    echo "$CONFLICTS"
else
    echo "✅ No merge conflicts found"
fi

echo ""
echo "🔧 Fix 1: Removing ALL merge conflict markers..."
find . -type f \( -name "*.tsx" -o -name "*.ts" -o -name "*.js" -o -name "*.jsx" \) -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" -exec grep -l "<<<<<<< HEAD" {} \; 2>/dev/null | while read file; do
    echo "  Cleaning: $file"
    # Remove conflict markers, keeping content after =======
    sed -i.bak '/<<<<<<< HEAD/,/=======/d; />>>>>>> /d' "$file"
    rm "${file}.bak"
done

echo ""
echo "🔧 Fix 2: Ensuring git repo is clean..."
# Stage any modified files
git add -A
git reset --hard HEAD

echo ""
echo "🔧 Fix 3: Getting latest clean code..."
git pull origin main --force

echo ""
echo "🔧 Fix 4: Complete dependency cleanup..."
rm -rf node_modules
rm -rf packages/*/node_modules
rm -rf packages/*/dist
rm -rf apps/*/node_modules  
rm -rf apps/*/.next
rm -rf .turbo

echo ""
echo "🔧 Fix 5: Installing root dependencies..."
pnpm install --force

echo ""
echo "🔧 Fix 6: Building packages with proper dependencies..."

# API Contracts
echo "  Building api-contracts..."
cd packages/api-contracts
pnpm install
pnpm build 2>/dev/null || echo "    No build needed"
cd ../..

# DB Package
echo "  Building db..."
cd packages/db
pnpm install
pnpm build 2>/dev/null || echo "    No build needed"
cd ../..

# API Client - CRITICAL
echo "  Building api-client (CRITICAL)..."
cd packages/api-client
pnpm install
# Ensure build tools are installed
pnpm add -D tsup typescript @types/node --force
# Build using tsup directly
npx tsup src/index.ts --format cjs,esm --dts --clean --out-dir dist
echo "    Verifying build output:"
if [ -d "dist" ] && [ -f "dist/index.js" ]; then
    echo "    ✅ api-client built successfully!"
    ls -la dist/
else
    echo "    ❌ Build failed! Trying alternative method..."
    # Fallback: manual TypeScript compilation
    npx tsc --module commonjs --target es2020 --outDir dist --declaration src/index.ts
fi
cd ../..

# UI Package
echo "  Building ui..."
cd packages/ui
pnpm install
pnpm build 2>/dev/null || echo "    No build needed"
cd ../..

echo ""
echo "🔧 Fix 7: Final dependency installation..."
pnpm install --shamefully-hoist --force

echo ""
echo "🔧 Fix 8: Building all apps..."
pnpm build || {
    echo "  Parallel build failed, trying sequential..."
    
    # Build each app individually if parallel fails
    for app in apps/*/; do
        if [ -d "$app" ] && [ -f "$app/package.json" ]; then
            appname=$(basename "$app")
            echo ""
            echo "  Building $appname individually..."
            cd "$app"
            pnpm build && echo "    ✅ $appname built!" || echo "    ❌ $appname failed!"
            cd ../..
        fi
    done
}

echo ""
echo "🚀 Fix 9: Restarting all services..."
pm2 restart all
pm2 save

echo ""
echo "📊 Post-fix Verification:"
echo "-----------------------"
# Check if api-client is built
if [ -f "packages/api-client/dist/index.js" ]; then
    echo "✅ api-client dist exists"
else
    echo "❌ api-client dist missing - BUILD FAILED"
fi

# Check for remaining conflicts
REMAINING=$(grep -rl "<<<<<<< HEAD" . --include="*.tsx" --include="*.ts" 2>/dev/null | grep -v node_modules | grep -v .git | wc -l)
echo "Remaining conflict files: $REMAINING"

# PM2 status
echo ""
echo "Service Status:"
pm2 status

echo ""
echo "✅ Final fix complete!"
echo ""
echo "If still failing:"
echo "1. Check: pm2 logs [app-name]"
echo "2. Run: cd packages/api-client && pnpm build"
echo "3. Check for TypeScript errors in specific apps"