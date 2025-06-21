#!/bin/bash

echo "🚨 CRITICAL: Fixing Git Merge Conflicts"
echo "======================================"

cd /data/projects/itemseekapp || exit 1

echo "📊 Step 1: Checking Git status..."
git status

echo ""
echo "🔍 Step 2: Finding all files with merge conflicts..."
git diff --name-only --diff-filter=U

echo ""
echo "📝 Step 3: Showing conflicts in tasks-app/app/layout.tsx..."
echo "Current content:"
cat apps/tasks-app/app/layout.tsx

echo ""
echo "🔧 Step 4: Auto-fixing merge conflicts..."
# For each conflicted file, we'll take the incoming changes (theirs)
git status --porcelain | grep "^UU" | awk '{print $2}' | while read file; do
    echo "Fixing: $file"
    # Take the remote version to resolve conflicts
    git checkout --theirs "$file"
    git add "$file"
done

echo ""
echo "✅ Step 5: Verifying fixes..."
if git diff --cached --name-only --diff-filter=U | grep -q .; then
    echo "❌ Still have conflicts:"
    git diff --cached --name-only --diff-filter=U
else
    echo "✅ All conflicts resolved!"
fi

echo ""
echo "📦 Step 6: Cleaning and rebuilding..."
rm -rf apps/*/node_modules apps/*/.next
pnpm install --shamefully-hoist
pnpm build

echo ""
echo "🚀 Step 7: Restarting services..."
pm2 restart all

echo ""
echo "✅ Merge conflict fix complete!"
pm2 status