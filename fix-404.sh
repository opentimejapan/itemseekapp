#!/bin/bash

echo "🔍 Debugging 404 Error on ItemSeek"
echo "=================================="
echo ""

# Step 1: Check if apps are running
echo "1. Checking if apps are running with PM2..."
if command -v pm2 &> /dev/null; then
    pm2_status=$(pm2 list | grep -E "api-gateway|inventory|tasks|locations" | wc -l)
    if [ "$pm2_status" -gt 0 ]; then
        echo "✅ Found PM2 apps running:"
        pm2 list
    else
        echo "❌ No PM2 apps running!"
        echo "   Starting apps now..."
        cd /var/www/itemseekapp
        pm2 start ecosystem.config.js
    fi
else
    echo "❌ PM2 not installed!"
fi

# Step 2: Check if ports are listening
echo ""
echo "2. Checking if ports are listening..."
for port in 3000 3001 3002 3003; do
    if ss -tuln | grep -q ":$port "; then
        echo "✅ Port $port is listening"
        # Test if the port responds
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:$port | grep -q "200\|302"; then
            echo "   ✅ Port $port is responding"
        else
            echo "   ❌ Port $port is NOT responding"
        fi
    else
        echo "❌ Port $port is NOT listening"
    fi
done

# Step 3: Check nginx configuration
echo ""
echo "3. Checking nginx configuration..."
if [ -f "/etc/nginx/sites-enabled/itemseek" ]; then
    echo "✅ ItemSeek nginx config is enabled"
    echo "   Testing nginx config..."
    nginx -t
else
    echo "❌ ItemSeek nginx config NOT enabled!"
    if [ -f "/etc/nginx/sites-available/itemseek" ]; then
        echo "   Enabling it now..."
        ln -sf /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/
        systemctl reload nginx
    else
        echo "   Creating nginx config..."
        cat > /etc/nginx/sites-available/itemseek << 'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /inventory {
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /tasks {
        proxy_pass http://127.0.0.1:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
    
    location /locations {
        proxy_pass http://127.0.0.1:3003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
        ln -sf /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/
        rm -f /etc/nginx/sites-enabled/default
        nginx -t && systemctl reload nginx
    fi
fi

# Step 4: Check default site
echo ""
echo "4. Checking for conflicting default site..."
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    echo "⚠️  Default site is enabled! Removing it..."
    rm -f /etc/nginx/sites-enabled/default
    systemctl reload nginx
else
    echo "✅ No conflicting default site"
fi

# Step 5: Check nginx error log
echo ""
echo "5. Recent nginx errors:"
tail -5 /var/log/nginx/error.log

# Step 6: Test direct access
echo ""
echo "6. Testing direct access to apps..."
echo "   Testing API Gateway (port 3000)..."
curl -I http://localhost:3000 2>/dev/null | head -n 1

# Step 7: Show current nginx sites
echo ""
echo "7. Current nginx enabled sites:"
ls -la /etc/nginx/sites-enabled/

# Step 8: Show nginx config
echo ""
echo "8. Current nginx config for ItemSeek:"
if [ -f "/etc/nginx/sites-available/itemseek" ]; then
    cat /etc/nginx/sites-available/itemseek | head -20
else
    echo "No ItemSeek config found!"
fi

# Step 9: Quick fix attempt
echo ""
echo "9. Attempting quick fix..."
echo "   Restarting services..."
pm2 restart all
systemctl restart nginx

echo ""
echo "=================================="
echo "Diagnostic complete!"
echo ""
echo "Try accessing http://172.104.117.4 now"
echo ""
echo "If still not working, run:"
echo "  pm2 logs api-gateway"
echo "  journalctl -u nginx -n 50"