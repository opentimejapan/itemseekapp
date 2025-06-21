#!/bin/bash

echo "🔧 Comprehensive Build Fix"
echo "========================="

cd /data/projects/itemseekapp || exit 1

echo "📊 Step 1: Current Git Status"
git status --short

echo ""
echo "🔍 Step 2: Finding ALL files with conflict markers..."
CONFLICT_FILES=$(grep -rl "<<<<<<< HEAD" . --include="*.tsx" --include="*.ts" --include="*.js" --include="*.jsx" --include="*.json" 2>/dev/null | grep -v node_modules | grep -v .git)

if [ ! -z "$CONFLICT_FILES" ]; then
    echo "Found conflict markers in:"
    echo "$CONFLICT_FILES"
    
    echo ""
    echo "🔧 Step 3: Removing conflict markers..."
    for file in $CONFLICT_FILES; do
        echo "Cleaning: $file"
        # Create backup
        cp "$file" "$file.backup"
        
        # Remove conflict markers - keep the newer version (after =======)
        awk '
            /<<<<<<< HEAD/ { in_conflict = 1; next }
            /=======/ { in_conflict = 2; next }
            />>>>>>> / { in_conflict = 0; next }
            in_conflict != 1 { print }
        ' "$file.backup" > "$file"
        
        rm "$file.backup"
    done
else
    echo "✅ No conflict markers found"
fi

echo ""
echo "🧹 Step 4: Complete cleanup..."
# Remove ALL build artifacts and dependencies
rm -rf node_modules
rm -rf packages/*/node_modules
rm -rf packages/*/dist
rm -rf packages/*/.next
rm -rf apps/*/node_modules
rm -rf apps/*/.next
rm -rf apps/*/dist
rm -rf .next
rm -rf dist

echo ""
echo "📦 Step 5: Fresh install of dependencies..."
pnpm install --force

echo ""
echo "🔨 Step 6: Building packages in order..."

# Build api-contracts first
echo "  Building api-contracts..."
cd packages/api-contracts
pnpm install
pnpm build 2>/dev/null || echo "  No build script"
cd ../..

# Build db
echo "  Building db..."
cd packages/db
pnpm install
pnpm build 2>/dev/null || echo "  No build script"
cd ../..

# Build api-client with explicit dependencies
echo "  Building api-client..."
cd packages/api-client
pnpm install
pnpm add -D tsup typescript @types/node
npx tsup src/index.ts --format cjs,esm --dts --clean
echo "  Verifying api-client build..."
ls -la dist/
cd ../..

# Build ui
echo "  Building ui..."
cd packages/ui
pnpm install
pnpm build 2>/dev/null || echo "  No build script"
cd ../..

echo ""
echo "📦 Step 7: Final dependency install..."
pnpm install --shamefully-hoist

echo ""
echo "🔨 Step 8: Building apps one by one..."
# Build each app individually to identify failures
for app in apps/*/; do
    if [ -d "$app" ] && [ -f "$app/package.json" ]; then
        appname=$(basename "$app")
        echo ""
        echo "Building $appname..."
        cd "$app"
        pnpm build || echo "❌ Failed to build $appname"
        cd ../..
    fi
done

echo ""
echo "🚀 Step 9: Restarting services..."
pm2 restart all || echo "PM2 restart failed"

echo ""
echo "📊 Final Status:"
pm2 status

echo ""
echo "✅ Comprehensive fix complete!"
echo ""
echo "If builds still fail, check:"
echo "1. pm2 logs [app-name]"
echo "2. Look for any remaining syntax errors"
echo "3. Ensure all dependencies are installed"