#!/bin/bash

# Full Stack Deployment Script for ItemSeek
# Deploys both frontend and backend to Ubuntu server

SERVER_IP="172.104.117.4"
SERVER_USER="root"

echo "🚀 Full Stack ItemSeek Deployment"
echo "================================="
echo "This will deploy both frontend and backend"
echo ""

# Create the deployment script that will run on server
cat > server-deploy.sh << 'EOF'
#!/bin/bash

echo "🚀 ItemSeek Full Stack Installation"
echo "==================================="

# Install system dependencies
echo "📦 Installing system dependencies..."
apt-get update
apt-get install -y curl git build-essential nginx postgresql postgresql-contrib

# Install Node.js 18
if ! command -v node &> /dev/null; then
    echo "📦 Installing Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi

# Install global packages
echo "📦 Installing pnpm and pm2..."
npm install -g pnpm pm2

# Setup PostgreSQL
echo "🐘 Setting up PostgreSQL..."
sudo -u postgres psql << SQL
CREATE USER itemseek WITH PASSWORD 'itemseek123';
CREATE DATABASE itemseek;
GRANT ALL PRIVILEGES ON DATABASE itemseek TO itemseek;
SQL

# Clone/Update Backend
echo "📂 Setting up Backend..."
cd /var/www
if [ -d "itemseekapp-backend" ]; then
    cd itemseekapp-backend
    git pull origin main
else
    git clone https://github.com/opentimejapan/itemseekapp-backend.git
    cd itemseekapp-backend
fi

# Install backend dependencies and setup
echo "📦 Installing backend dependencies..."
pnpm install

# Create .env file for backend
cat > .env << ENV
DATABASE_URL=postgresql://itemseek:itemseek123@localhost:5432/itemseek
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
PORT=3100
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001,http://localhost:3002,http://localhost:3003,http://172.104.117.4
ENV

# Build and setup database
echo "🔨 Building backend..."
pnpm build

echo "🗄️ Running database migrations..."
pnpm db:push
pnpm db:seed

# Clone/Update Frontend
echo "📂 Setting up Frontend..."
cd /var/www
if [ -d "itemseekapp" ]; then
    cd itemseekapp
    git pull origin main
else
    git clone https://github.com/opentimejapan/itemseekapp.git
    cd itemseekapp
fi

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
pnpm install

# Build frontend apps
echo "🔨 Building frontend apps..."
pnpm build

# Setup PM2 for backend
echo "🚀 Starting backend with PM2..."
cd /var/www/itemseekapp-backend
pm2 delete backend 2>/dev/null || true
pm2 start npm --name backend -- start
pm2 save

# Setup PM2 for frontend
echo "🚀 Starting frontend apps with PM2..."
cd /var/www/itemseekapp

# Create PM2 config
cat > ecosystem.config.js << 'PM2'
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
PM2

pm2 delete all 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u root --hp /root

# Configure Nginx
echo "🔧 Configuring Nginx..."
cat > /etc/nginx/sites-available/itemseek << 'NGINX'
# Backend API
upstream backend_api {
    server 127.0.0.1:3100;
}

server {
    listen 80;
    server_name _;

    # API routes go to backend
    location /api {
        proxy_pass http://backend_api;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

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
        proxy_cache_valid 200 60m;
        add_header Cache-Control "public, immutable";
    }
}
NGINX

# Enable site
rm -f /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Create update script
cat > /usr/local/bin/update-itemseek.sh << 'UPDATE'
#!/bin/bash
echo "🔄 Updating ItemSeek..."

# Update backend
cd /var/www/itemseekapp-backend
git pull origin main
pnpm install
pnpm build
pnpm db:migrate
pm2 restart backend

# Update frontend
cd /var/www/itemseekapp
git pull origin main
pnpm install
pnpm build
pm2 restart api-gateway inventory tasks locations

echo "✅ Update complete!"
UPDATE

chmod +x /usr/local/bin/update-itemseek.sh

echo ""
echo "✅ Full Stack Deployment Complete!"
echo "=================================="
echo ""
echo "🌐 Access your apps at:"
echo "   Main: http://172.104.117.4"
echo "   Signup: http://172.104.117.4/signup"
echo "   Login: http://172.104.117.4/login"
echo "   Inventory: http://172.104.117.4/inventory"
echo "   Tasks: http://172.104.117.4/tasks"
echo "   Locations: http://172.104.117.4/locations"
echo ""
echo "📊 Services Status:"
pm2 status
echo ""
echo "🔧 Useful commands:"
echo "   pm2 logs              - View all logs"
echo "   pm2 logs backend      - View backend logs"
echo "   pm2 restart all       - Restart everything"
echo "   update-itemseek.sh    - Update to latest code"
echo ""
echo "📝 Default login: demo@itemseek.com / demo123"
EOF

# Copy and run the script on server
echo "📤 Deploying to server..."
scp server-deploy.sh $SERVER_USER@$SERVER_IP:/tmp/
ssh $SERVER_USER@$SERVER_IP "chmod +x /tmp/server-deploy.sh && /tmp/server-deploy.sh"

# Cleanup
rm server-deploy.sh

echo "✅ Deployment initiated on server!"