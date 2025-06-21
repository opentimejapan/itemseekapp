#!/bin/bash

echo "🚀 Fresh Install of ItemSeek"
echo "============================"
echo ""
echo "This script will do a complete fresh installation"
echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
sleep 5

# Stop everything first
echo "🛑 Stopping existing services..."
pm2 kill || true
systemctl stop nginx || true

# Install dependencies
echo "📦 Installing system dependencies..."
apt-get update
apt-get install -y curl git build-essential nginx

# Install Node.js 18
echo "📦 Installing Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install global packages
echo "📦 Installing pnpm and pm2..."
npm install -g pnpm pm2

# Remove old installation
echo "🧹 Removing old installation..."
rm -rf /var/www/itemseekapp

# Clone fresh
echo "📂 Cloning fresh repository..."
cd /var/www
git clone https://github.com/opentimejapan/itemseekapp.git
cd itemseekapp

# Install dependencies
echo "📦 Installing app dependencies..."
pnpm install

# Build apps
echo "🔨 Building apps..."
pnpm build

# Create simple PM2 config
echo "📝 Creating PM2 config..."
cat > start-apps.sh << 'EOF'
#!/bin/bash
cd /var/www/itemseekapp

# Start each app separately
pm2 start --name api-gateway "pnpm --filter api-gateway start"
pm2 start --name inventory "pnpm --filter inventory-app start"
pm2 start --name tasks "pnpm --filter tasks-app start"
pm2 start --name locations "pnpm --filter locations-app start"

pm2 save
EOF

chmod +x start-apps.sh

# Start apps
echo "🚀 Starting apps..."
./start-apps.sh

# Setup PM2 startup
pm2 startup systemd -u root --hp /root
pm2 save

# Configure nginx - SIMPLE VERSION
echo "🔧 Configuring nginx (simple version)..."
cat > /etc/nginx/sites-available/itemseek << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

# Remove ALL other sites
rm -f /etc/nginx/sites-enabled/*

# Enable our site
ln -s /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/itemseek

# Start nginx
systemctl start nginx
systemctl enable nginx

# Test and reload
nginx -t
systemctl reload nginx

# Wait for apps to start
echo "⏳ Waiting for apps to fully start (30 seconds)..."
sleep 30

# Final check
echo ""
echo "✅ Installation complete!"
echo ""
echo "📊 PM2 Status:"
pm2 status
echo ""
echo "🧪 Testing main page..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)
if [ "$response" = "200" ]; then
    echo "✅ Main app is responding!"
else
    echo "⚠️  Main app returned: $response"
    echo "   Check logs: pm2 logs api-gateway"
fi

echo ""
echo "🧪 Testing nginx proxy..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$response" = "200" ]; then
    echo "✅ Nginx proxy is working!"
else
    echo "⚠️  Nginx returned: $response"
    echo "   Check: systemctl status nginx"
fi

echo ""
echo "🌐 Your site should now be available at:"
echo "   http://172.104.117.4"
echo ""
echo "If not working, check:"
echo "   pm2 logs"
echo "   systemctl status nginx"
echo "   tail -f /var/log/nginx/error.log"