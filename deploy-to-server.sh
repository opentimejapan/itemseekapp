#!/bin/bash

# Deployment script for ItemSeek to Ubuntu Server
# Usage: ./deploy-to-server.sh

SERVER_IP="172.104.117.4"
SERVER_USER="root"
REMOTE_DIR="/var/www/itemseekapp"

echo "🚀 Starting deployment to $SERVER_IP..."

# Step 1: Build the apps locally first
echo "📦 Building apps locally..."
export PNPM_HOME="/Users/kyleburns/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

pnpm install
pnpm build

# Step 2: Create deployment package
echo "📦 Creating deployment package..."
tar -czf deploy.tar.gz \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='.next' \
  --exclude='dist' \
  --exclude='.turbo' \
  .

# Step 3: Copy to server
echo "📤 Copying files to server..."
scp deploy.tar.gz $SERVER_USER@$SERVER_IP:/tmp/

# Step 4: Setup script for server
cat > setup-server.sh << 'EOF'
#!/bin/bash

echo "🔧 Setting up ItemSeek on server..."

# Install Node.js 18 if not present
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install pnpm if not present
if ! command -v pnpm &> /dev/null; then
    echo "📦 Installing pnpm..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    source ~/.bashrc
fi

# Install PM2 if not present
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    npm install -g pm2
fi

# Create app directory
sudo mkdir -p /var/www/itemseekapp
cd /var/www

# Extract files
echo "📂 Extracting files..."
sudo tar -xzf /tmp/deploy.tar.gz -C /var/www/itemseekapp
sudo chown -R www-data:www-data /var/www/itemseekapp

# Install dependencies
cd /var/www/itemseekapp
echo "📦 Installing dependencies..."
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
pnpm install --production

# Build the apps
echo "🔨 Building apps..."
pnpm build

# Create PM2 ecosystem file
cat > ecosystem.config.js << 'PM2EOF'
module.exports = {
  apps: [
    {
      name: 'api-gateway',
      cwd: '/var/www/itemseekapp/apps/api-gateway',
      script: 'node_modules/.bin/next',
      args: 'start -p 3000',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      }
    },
    {
      name: 'inventory-app',
      cwd: '/var/www/itemseekapp/apps/inventory-app',
      script: 'node_modules/.bin/next',
      args: 'start -p 3001',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      }
    },
    {
      name: 'tasks-app',
      cwd: '/var/www/itemseekapp/apps/tasks-app',
      script: 'node_modules/.bin/next',
      args: 'start -p 3002',
      env: {
        NODE_ENV: 'production',
        PORT: 3002
      }
    },
    {
      name: 'locations-app',
      cwd: '/var/www/itemseekapp/apps/locations-app',
      script: 'node_modules/.bin/next',
      args: 'start -p 3003',
      env: {
        NODE_ENV: 'production',
        PORT: 3003
      }
    }
  ]
};
PM2EOF

# Stop existing PM2 apps if running
pm2 stop all || true
pm2 delete all || true

# Start apps with PM2
echo "🚀 Starting apps with PM2..."
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u $USER --hp /home/$USER || true

# Configure Nginx
echo "🔧 Configuring Nginx..."
sudo tee /etc/nginx/sites-available/itemseek > /dev/null << 'NGINXEOF'
server {
    listen 80;
    server_name 172.104.117.4;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Main app (API Gateway)
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Signup page
    location /signup {
        proxy_pass http://localhost:3000/signup;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Login page
    location /login {
        proxy_pass http://localhost:3000/login;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Inventory app
    location /inventory {
        proxy_pass http://localhost:3001;
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
        proxy_pass http://localhost:3002;
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
        proxy_pass http://localhost:3003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # API routes
    location /api {
        proxy_pass http://localhost:3000/api;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # Static files with caching
    location /_next/static {
        proxy_pass http://localhost:3000/_next/static;
        proxy_cache_valid 60m;
        add_header Cache-Control "public, immutable";
    }
}
NGINXEOF

# Remove default nginx site if exists
sudo rm -f /etc/nginx/sites-enabled/default

# Enable the site
sudo ln -sf /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Update the redirect URLs in the apps
echo "🔧 Updating redirect URLs for production..."
cd /var/www/itemseekapp

# Update signup page redirect
sudo sed -i "s|window.location.href = 'http://localhost:3001';|window.location.href = '/inventory';|g" apps/api-gateway/app/signup/page.tsx

# Update login page redirect  
sudo sed -i "s|window.location.href = 'http://localhost:3001';|window.location.href = '/inventory';|g" apps/api-gateway/app/login/page.tsx

# Rebuild api-gateway with updated URLs
cd apps/api-gateway
pnpm build
cd ../..

# Restart api-gateway to pick up changes
pm2 restart api-gateway

echo "✅ Deployment complete!"
echo ""
echo "🌐 Your apps are now available at:"
echo "   Main site: http://172.104.117.4"
echo "   Signup: http://172.104.117.4/signup"
echo "   Login: http://172.104.117.4/login"
echo "   Inventory: http://172.104.117.4/inventory"
echo "   Tasks: http://172.104.117.4/tasks"
echo "   Locations: http://172.104.117.4/locations"
echo ""
echo "📊 Check status with: pm2 status"
echo "📝 View logs with: pm2 logs"

# Cleanup
rm -f /tmp/deploy.tar.gz
EOF

# Step 5: Copy setup script to server and run it
echo "🚀 Running setup on server..."
scp setup-server.sh $SERVER_USER@$SERVER_IP:/tmp/
ssh $SERVER_USER@$SERVER_IP "chmod +x /tmp/setup-server.sh && /tmp/setup-server.sh"

# Cleanup
rm -f deploy.tar.gz setup-server.sh

echo "✅ Deployment complete!"
echo "🌐 Visit http://$SERVER_IP to see your site"