#!/bin/bash

echo "🔍 ItemSeek Server Diagnostic Script"
echo "===================================="
echo ""

# Check if Node.js is installed
echo "1. Checking Node.js..."
if command -v node &> /dev/null; then
    echo "✅ Node.js installed: $(node -v)"
else
    echo "❌ Node.js NOT installed"
fi

# Check if pnpm is installed
echo ""
echo "2. Checking pnpm..."
if command -v pnpm &> /dev/null; then
    echo "✅ pnpm installed: $(pnpm -v)"
else
    echo "❌ pnpm NOT installed"
fi

# Check if PM2 is installed
echo ""
echo "3. Checking PM2..."
if command -v pm2 &> /dev/null; then
    echo "✅ PM2 installed"
    echo "Running processes:"
    pm2 list
else
    echo "❌ PM2 NOT installed"
fi

# Check if the app directory exists
echo ""
echo "4. Checking app directory..."
if [ -d "/var/www/itemseekapp" ]; then
    echo "✅ App directory exists"
    cd /var/www/itemseekapp
    if [ -d ".git" ]; then
        echo "✅ Git repository found"
        echo "Current branch: $(git branch --show-current)"
        echo "Last commit: $(git log -1 --oneline)"
    fi
    if [ -d "node_modules" ]; then
        echo "✅ Dependencies installed"
    else
        echo "❌ Dependencies NOT installed"
    fi
else
    echo "❌ App directory NOT found at /var/www/itemseekapp"
fi

# Check nginx configuration
echo ""
echo "5. Checking Nginx..."
if [ -f "/etc/nginx/sites-available/itemseek" ]; then
    echo "✅ ItemSeek nginx config exists"
    if [ -L "/etc/nginx/sites-enabled/itemseek" ]; then
        echo "✅ ItemSeek site enabled"
    else
        echo "❌ ItemSeek site NOT enabled"
    fi
else
    echo "❌ ItemSeek nginx config NOT found"
fi

# Check if ports are listening
echo ""
echo "6. Checking ports..."
for port in 3000 3001 3002 3003; do
    if netstat -tuln | grep -q ":$port "; then
        echo "✅ Port $port is listening"
    else
        echo "❌ Port $port is NOT listening"
    fi
done

echo ""
echo "===================================="
echo "Diagnostic complete!"
echo ""

# Provide fix commands based on what's missing
if ! command -v node &> /dev/null; then
    echo "To install Node.js, run:"
    echo "curl -fsSL https://deb.nodesource.com/setup_18.x | bash -"
    echo "apt-get install -y nodejs"
    echo ""
fi

if ! command -v pnpm &> /dev/null; then
    echo "To install pnpm, run:"
    echo "npm install -g pnpm"
    echo ""
fi

if [ ! -d "/var/www/itemseekapp" ]; then
    echo "To clone the repository, run:"
    echo "cd /var/www"
    echo "git clone https://github.com/opentimejapan/itemseekapp.git"
    echo ""
fi