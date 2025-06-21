#!/bin/bash

echo "🚨 IMMEDIATE FIX - Resolving Merge Conflicts on Server"
echo "===================================================="

ssh root@172.104.117.4 << 'EOF'
cd /data/projects/itemseekapp

echo "🔍 Finding files with merge conflicts..."
conflicted_files=$(git diff --name-only --diff-filter=U)

if [ -z "$conflicted_files" ]; then
    echo "No merge conflicts found. Checking for conflict markers..."
    # Find files with conflict markers
    grep -r "<<<<<<< HEAD" apps/ --include="*.tsx" --include="*.ts" --include="*.js" --include="*.jsx" | cut -d: -f1 | sort -u | while read file; do
        echo "Found conflict markers in: $file"
        # Remove conflict markers and keep the second version
        sed -i '/<<<<<<< HEAD/,/=======/d' "$file"
        sed -i '/>>>>>>> /d' "$file"
    done
else
    echo "Found conflicted files:"
    echo "$conflicted_files"
    
    # Resolve by taking remote version
    echo "$conflicted_files" | while read file; do
        echo "Resolving: $file"
        git checkout --theirs "$file"
        git add "$file"
    done
fi

echo ""
echo "📦 Reinstalling and rebuilding..."
rm -rf apps/*/node_modules apps/*/.next packages/*/dist
pnpm install --shamefully-hoist

# Build api-client first
cd packages/api-client
pnpm add -D tsup typescript @types/node
pnpm build
cd ../..

# Build everything
pnpm build

echo ""
echo "🚀 Restarting services..."
pm2 restart all
pm2 status

echo "✅ Emergency fix complete!"
EOF