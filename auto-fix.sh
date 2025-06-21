#!/bin/bash

# Automated Fix Script for ItemSeek
# This script attempts to fix all common issues automatically

echo "🔧 ItemSeek Automated Fix Script"
echo "================================"
echo ""

# Function to fix issues
fix_issue() {
    echo "🔧 Fixing: $1"
    $2
    if [ $? -eq 0 ]; then
        echo "✅ Fixed: $1"
    else
        echo "❌ Failed to fix: $1"
    fi
    echo ""
}

# Check if we're root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

# Fix 1: Install missing dependencies
if ! command -v node &> /dev/null; then
    fix_issue "Installing Node.js" "curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs"
fi

if ! command -v pnpm &> /dev/null; then
    fix_issue "Installing pnpm" "npm install -g pnpm"
fi

if ! command -v pm2 &> /dev/null; then
    fix_issue "Installing PM2" "npm install -g pm2"
fi

# Fix 2: Clone or update repository
if [ ! -d "/var/www/itemseekapp" ]; then
    fix_issue "Cloning repository" "cd /var/www && git clone https://github.com/opentimejapan/itemseekapp.git"
else
    fix_issue "Updating repository" "cd /var/www/itemseekapp && git fetch && git reset --hard origin/main"
fi

cd /var/www/itemseekapp

# Fix 3: Install dependencies
if [ ! -d "node_modules" ] || [ ! -d "apps/api-gateway/node_modules" ]; then
    fix_issue "Installing dependencies" "pnpm install"
fi

# Fix 4: Build applications
build_needed=false
for app in api-gateway inventory-app tasks-app locations-app; do
    if [ ! -d "apps/$app/.next" ]; then
        build_needed=true
        break
    fi
done

if [ "$build_needed" = true ]; then
    fix_issue "Building applications" "pnpm build"
fi

# Fix 5: Fix PM2 processes
echo "🔧 Fixing PM2 processes..."
pm2 delete all 2>/dev/null || true

# Create a working PM2 config
cat > /var/www/itemseekapp/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'api-gateway',
      script: './node_modules/.bin/next',
      args: 'start',
      cwd: '/var/www/itemseekapp/apps/api-gateway',
      env: { PORT: 3000 }
    },
    {
      name: 'inventory',
      script: './node_modules/.bin/next',
      args: 'start',
      cwd: '/var/www/itemseekapp/apps/inventory-app',
      env: { PORT: 3001 }
    },
    {
      name: 'tasks',
      script: './node_modules/.bin/next',
      args: 'start',
      cwd: '/var/www/itemseekapp/apps/tasks-app',
      env: { PORT: 3002 }
    },
    {
      name: 'locations',
      script: './node_modules/.bin/next',
      args: 'start',
      cwd: '/var/www/itemseekapp/apps/locations-app',
      env: { PORT: 3003 }
    }
  ]
};
EOF

fix_issue "Starting PM2 apps" "pm2 start ecosystem.config.js"
pm2 save

# Fix 6: Fix nginx configuration
echo "🔧 Fixing nginx configuration..."

# Remove all existing sites
rm -f /etc/nginx/sites-enabled/*

# Create proper nginx config
cat > /etc/nginx/sites-available/itemseek << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name _;

    # Disable nginx version in headers
    server_tokens off;

    # Main app
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

    # Next.js static files
    location /_next {
        proxy_pass http://127.0.0.1:3000/_next;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        
        # Cache static assets
        add_header Cache-Control "public, max-age=3600, immutable";
    }
}
EOF

# Enable the site
ln -s /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/itemseek

# Test and reload nginx
nginx -t
if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo "✅ Nginx configuration fixed"
else
    echo "❌ Nginx configuration has errors"
fi

# Fix 7: Ensure services start on boot
fix_issue "Setting up PM2 startup" "pm2 startup systemd -u root --hp /root"
fix_issue "Enabling nginx on boot" "systemctl enable nginx"

# Fix 8: Wait for services to stabilize
echo "⏳ Waiting for services to start (20 seconds)..."
sleep 20

# Fix 9: Final verification
echo ""
echo "🔍 Verifying fixes..."
echo ""

# Check PM2
echo "PM2 Status:"
pm2 list

echo ""
# Check if main page responds
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
if [ "$response" = "200" ]; then
    echo "✅ API Gateway responding on port 3000"
else
    echo "❌ API Gateway not responding (HTTP $response)"
fi

# Check nginx proxy
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$response" = "200" ]; then
    echo "✅ Nginx proxy working"
else
    echo "❌ Nginx proxy not working (HTTP $response)"
fi

# Check external access
response=$(curl -s -o /dev/null -w "%{http_code}" http://172.104.117.4/)
if [ "$response" = "200" ]; then
    echo "✅ External access working"
else
    echo "❌ External access not working (HTTP $response)"
fi

echo ""
echo "================================"
echo "Fix script complete!"
echo ""
echo "🌐 Try accessing:"
echo "   http://172.104.117.4"
echo "   http://172.104.117.4/signup"
echo "   http://172.104.117.4/login"
echo ""
echo "If still having issues:"
echo "1. Check logs: pm2 logs api-gateway"
echo "2. Check nginx: tail -f /var/log/nginx/error.log"
echo "3. Restart everything: pm2 restart all && systemctl restart nginx"