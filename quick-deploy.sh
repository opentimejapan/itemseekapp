#!/bin/bash

# Quick deployment commands to run on the server
# Copy and paste these commands after SSH-ing into your server

echo "🚀 Quick ItemSeek Deployment Script"
echo "===================================="

# Check if we're on the server
if [ ! -f /etc/nginx/nginx.conf ]; then
    echo "❌ This script should be run on your Ubuntu server!"
    echo "   Please SSH into your server first:"
    echo "   ssh root@172.104.117.4"
    exit 1
fi

# Install Node.js 18 if needed
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
else
    echo "✅ Node.js already installed: $(node -v)"
fi

# Install pnpm
if ! command -v pnpm &> /dev/null; then
    echo "📦 Installing pnpm..."
    npm install -g pnpm
else
    echo "✅ pnpm already installed"
fi

# Install PM2
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    npm install -g pm2
else
    echo "✅ PM2 already installed"
fi

# Clone or update the repository
echo "📂 Setting up application files..."
cd /var/www
if [ -d "itemseekapp" ]; then
    echo "📂 Updating existing repository..."
    cd itemseekapp
    git pull origin main
else
    echo "📂 Cloning repository..."
    git clone https://github.com/opentimejapan/itemseekapp.git
    cd itemseekapp
fi

# Install dependencies
echo "📦 Installing dependencies (this may take a few minutes)..."
pnpm install

# Build all applications
echo "🔨 Building applications..."
pnpm build

# Create a simple PM2 start script
echo "🚀 Starting applications with PM2..."

# Kill any existing PM2 processes
pm2 kill

# Start each app
cd /var/www/itemseekapp
pm2 start npm --name "api-gateway" --cwd ./apps/api-gateway -- start
pm2 start npm --name "inventory" --cwd ./apps/inventory-app -- start  
pm2 start npm --name "tasks" --cwd ./apps/tasks-app -- start
pm2 start npm --name "locations" --cwd ./apps/locations-app -- start

# Save PM2 config
pm2 save
pm2 startup systemd -u root --hp /root

# Configure Nginx
echo "🔧 Configuring Nginx..."
cat > /etc/nginx/sites-available/itemseek << 'NGINX_CONFIG'
server {
    listen 80;
    server_name 172.104.117.4;

    # Main app and auth pages
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
    }

    # Inventory app
    location /inventory {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Tasks app
    location /tasks {
        proxy_pass http://127.0.0.1:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Locations app
    location /locations {
        proxy_pass http://127.0.0.1:3003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Static files
    location /_next {
        proxy_pass http://127.0.0.1:3000/_next;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINX_CONFIG

# Enable the site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/itemseek

# Test and reload nginx
nginx -t && systemctl reload nginx

# Show status
echo ""
echo "✅ Deployment Complete!"
echo "======================="
echo ""
echo "📊 PM2 Status:"
pm2 status
echo ""
echo "🌐 Your apps should now be available at:"
echo "   Main site: http://172.104.117.4"
echo "   Signup: http://172.104.117.4/signup"  
echo "   Login: http://172.104.117.4/login"
echo "   Inventory: http://172.104.117.4/inventory"
echo "   Tasks: http://172.104.117.4/tasks"
echo "   Locations: http://172.104.117.4/locations"
echo ""
echo "📝 Troubleshooting commands:"
echo "   pm2 logs        - View application logs"
echo "   pm2 restart all - Restart all apps"
echo "   nginx -t        - Test nginx config"
echo "   systemctl status nginx - Check nginx status"