#!/bin/bash

# Foolproof installation script for ItemSeek on Ubuntu Server
# This script handles all edge cases and errors

set -e  # Exit on error

echo "🚀 ItemSeek Installation Script"
echo "=============================="
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package list
echo "📦 Updating package list..."
apt-get update -y

# Install curl if not present
if ! command_exists curl; then
    echo "📦 Installing curl..."
    apt-get install -y curl
fi

# Install Node.js 18
echo "📦 Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Verify Node.js installation
echo "✅ Node.js version: $(node -v)"
echo "✅ npm version: $(npm -v)"

# Install build essentials (needed for some npm packages)
echo "📦 Installing build tools..."
apt-get install -y build-essential

# Install pnpm globally
echo "📦 Installing pnpm..."
npm install -g pnpm

# Install PM2 globally
echo "📦 Installing PM2..."
npm install -g pm2

# Create web directory if it doesn't exist
echo "📂 Creating /var/www directory..."
mkdir -p /var/www
cd /var/www

# Clone or update repository
if [ -d "itemseekapp" ]; then
    echo "📂 Updating existing repository..."
    cd itemseekapp
    git fetch origin
    git reset --hard origin/main
else
    echo "📂 Cloning repository..."
    git clone https://github.com/opentimejapan/itemseekapp.git
    cd itemseekapp
fi

# Clean install dependencies
echo "🧹 Cleaning old dependencies..."
rm -rf node_modules
rm -rf apps/*/node_modules
rm -rf packages/*/node_modules

echo "📦 Installing dependencies (this will take a few minutes)..."
pnpm install

# Build all applications
echo "🔨 Building applications..."
pnpm build

# Stop any existing PM2 processes
echo "🛑 Stopping existing PM2 processes..."
pm2 delete all || true

# Create PM2 ecosystem file
echo "📝 Creating PM2 configuration..."
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'api-gateway',
      script: 'pnpm',
      args: 'start',
      cwd: '/var/www/itemseekapp/apps/api-gateway',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      }
    },
    {
      name: 'inventory',
      script: 'pnpm',
      args: 'start',
      cwd: '/var/www/itemseekapp/apps/inventory-app',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      }
    },
    {
      name: 'tasks',
      script: 'pnpm',
      args: 'start',
      cwd: '/var/www/itemseekapp/apps/tasks-app',
      env: {
        NODE_ENV: 'production',
        PORT: 3002
      }
    },
    {
      name: 'locations',
      script: 'pnpm',
      args: 'start',
      cwd: '/var/www/itemseekapp/apps/locations-app',
      env: {
        NODE_ENV: 'production',
        PORT: 3003
      }
    }
  ]
};
EOF

# Start applications with PM2
echo "🚀 Starting applications..."
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save
pm2 startup systemd -u root --hp /root

# Install nginx if not present
if ! command_exists nginx; then
    echo "📦 Installing nginx..."
    apt-get install -y nginx
fi

# Configure nginx
echo "🔧 Configuring nginx..."
cat > /etc/nginx/sites-available/itemseek << 'EOF'
server {
    listen 80;
    server_name _;

    # Increase buffer sizes
    client_body_buffer_size 16K;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 16k;

    # Main app (API Gateway)
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Inventory app
    location /inventory {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Tasks app
    location /tasks {
        proxy_pass http://127.0.0.1:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Locations app
    location /locations {
        proxy_pass http://127.0.0.1:3003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Next.js static files
    location /_next {
        proxy_pass http://127.0.0.1:3000/_next;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        
        # Cache static assets
        proxy_cache_valid 200 60m;
        proxy_cache_valid 404 1m;
    }
}
EOF

# Remove default site and enable itemseek
echo "🔧 Enabling nginx site..."
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
nginx -t

# Reload nginx
echo "🔄 Reloading nginx..."
systemctl reload nginx

# Wait for apps to start
echo "⏳ Waiting for applications to start..."
sleep 10

# Final status check
echo ""
echo "✅ Installation Complete!"
echo "========================"
echo ""
echo "📊 PM2 Status:"
pm2 status
echo ""
echo "🌐 Your applications are available at:"
echo "   Main site: http://172.104.117.4"
echo "   Signup: http://172.104.117.4/signup"
echo "   Login: http://172.104.117.4/login"
echo "   Inventory: http://172.104.117.4/inventory"
echo "   Tasks: http://172.104.117.4/tasks"
echo "   Locations: http://172.104.117.4/locations"
echo ""
echo "📝 Useful commands:"
echo "   pm2 logs          - View application logs"
echo "   pm2 restart all   - Restart all applications"
echo "   pm2 monit         - Monitor applications"
echo "   nginx -t          - Test nginx configuration"
echo ""

# Test if main page is accessible
echo "🧪 Testing main page..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
    echo "✅ Main page is accessible!"
else
    echo "⚠️  Main page might still be starting up. Wait 30 seconds and try again."
    echo "   Check logs with: pm2 logs api-gateway"
fi