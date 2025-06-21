# Simple Deployment Steps for Ubuntu Server

## Quick Deploy (Automated)

From your local machine, run:
```bash
./deploy-to-server.sh
```

This will automatically:
- Build the apps
- Copy files to server
- Install dependencies
- Configure nginx
- Start all apps with PM2

## Manual Deploy Steps

If you prefer to deploy manually or the script fails:

### 1. Connect to your server
```bash
ssh root@172.104.117.4
```

### 2. Install required software (if not already installed)
```bash
# Update packages
apt-get update

# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -
source ~/.bashrc

# Install PM2
npm install -g pm2

# Ensure nginx is installed
apt-get install -y nginx
```

### 3. Get the code on server
```bash
cd /var/www
git clone https://github.com/opentimejapan/itemseekapp.git
cd itemseekapp
```

### 4. Install dependencies and build
```bash
pnpm install
pnpm build
```

### 5. Start the apps with PM2
```bash
# Start all apps
pm2 start apps/api-gateway/package.json --name api-gateway -- start
pm2 start apps/inventory-app/package.json --name inventory -- start  
pm2 start apps/tasks-app/package.json --name tasks -- start
pm2 start apps/locations-app/package.json --name locations -- start

# Save PM2 configuration
pm2 save
pm2 startup
```

### 6. Configure Nginx

Create the nginx config:
```bash
nano /etc/nginx/sites-available/itemseek
```

Paste this configuration:
```nginx
server {
    listen 80;
    server_name 172.104.117.4;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /inventory {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /tasks {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /locations {
        proxy_pass http://localhost:3003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable the site:
```bash
ln -s /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx
```

### 7. Fix redirect URLs

Edit the signup page:
```bash
nano /var/www/itemseekapp/apps/api-gateway/app/signup/page.tsx
```

Change:
```javascript
window.location.href = 'http://localhost:3001';
```
To:
```javascript
window.location.href = '/inventory';
```

Do the same for login page:
```bash
nano /var/www/itemseekapp/apps/api-gateway/app/login/page.tsx
```

Rebuild api-gateway:
```bash
cd /var/www/itemseekapp/apps/api-gateway
pnpm build
pm2 restart api-gateway
```

## Verify Deployment

1. Check PM2 status:
```bash
pm2 status
```

2. Check nginx status:
```bash
systemctl status nginx
```

3. Visit your site:
- http://172.104.117.4 - Landing page
- http://172.104.117.4/signup - Signup page
- http://172.104.117.4/login - Login page
- http://172.104.117.4/inventory - Inventory app
- http://172.104.117.4/tasks - Tasks app
- http://172.104.117.4/locations - Locations app

## Troubleshooting

If you see 502 Bad Gateway:
```bash
# Check if apps are running
pm2 list
pm2 logs

# Restart apps
pm2 restart all

# Check nginx error log
tail -f /var/log/nginx/error.log
```

If styles are missing:
```bash
# Rebuild the apps
cd /var/www/itemseekapp
pnpm build
pm2 restart all
```