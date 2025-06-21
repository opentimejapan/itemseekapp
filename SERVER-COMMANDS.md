# Direct Server Commands

SSH into your server first:
```bash
ssh root@172.104.117.4
```

Then run these commands one by one:

## 1. Install Node.js and pnpm
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs
npm install -g pnpm pm2
```

## 2. Get the code
```bash
cd /var/www
git clone https://github.com/opentimejapan/itemseekapp.git
cd itemseekapp
```

## 3. Install and build
```bash
pnpm install
pnpm build
```

## 4. Start the apps
```bash
pm2 start npm --name "api-gateway" --cwd ./apps/api-gateway -- start
pm2 start npm --name "inventory" --cwd ./apps/inventory-app -- start  
pm2 start npm --name "tasks" --cwd ./apps/tasks-app -- start
pm2 start npm --name "locations" --cwd ./apps/locations-app -- start
pm2 save
```

## 5. Configure Nginx

Create the nginx config file:
```bash
cat > /etc/nginx/sites-available/itemseek << 'EOF'
server {
    listen 80;
    server_name 172.104.117.4;

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
```

## 6. Enable the site
```bash
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

## 7. Check if everything is running
```bash
pm2 status
```

## If you see any errors:
```bash
# Check logs
pm2 logs

# Restart apps
pm2 restart all

# Check nginx error log
tail -f /var/log/nginx/error.log
```