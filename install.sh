#!/bin/bash

echo "🚀 ItemSeek Installation Script"
echo "=============================="

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
    echo "pnpm not found. Installing via npm..."
    npm install -g pnpm
    
    if [ $? -ne 0 ]; then
        echo "Failed to install pnpm. Trying with corepack..."
        
        # Enable corepack (comes with Node.js 16+)
        corepack enable
        corepack prepare pnpm@latest --activate
    fi
fi

# Verify pnpm is available
if command -v pnpm &> /dev/null; then
    echo "✅ pnpm is installed: $(pnpm --version)"
    echo ""
    echo "Installing dependencies with pnpm..."
    pnpm install
else
    echo "❌ Failed to install pnpm"
    echo ""
    echo "Please install pnpm manually:"
    echo "Option 1: npm install -g pnpm"
    echo "Option 2: corepack enable && corepack prepare pnpm@latest --activate"
    echo "Option 3: curl -fsSL https://get.pnpm.io/install.sh | sh -"
    exit 1
fi