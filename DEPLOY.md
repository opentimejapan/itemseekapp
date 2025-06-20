# Deployment Instructions for Ubuntu Server (172.104.117.4)

## Prerequisites
- Ubuntu server with nginx installed
- Node.js 18+ installed
- PM2 for process management
- Git installed

## Step 1: Connect to your server
```bash
ssh root@172.104.117.4
```

## Step 2: Install required software
```bash
# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -
source ~/.bashrc

# Install PM2
npm install -g pm2
```

## Step 3: Clone and setup the repository
```bash
# Clone the repository
cd /var/www
git clone https://github.com/opentimejapan/itemseekapp.git
cd itemseekapp

# Install dependencies
pnpm install

# Build all apps
pnpm build
```

## Step 4: Configure PM2 to run the apps
Create a file called `ecosystem.config.js`:

```javascript
module.exports = {
  apps: [
    {
      name: 'api-gateway',
      cwd: '/var/www/itemseekapp/apps/api-gateway',
      script: 'npm',
      args: 'start',
      env: {
        PORT: 3000,
        NODE_ENV: 'production'
      }
    },
    {
      name: 'inventory-app',
      cwd: '/var/www/itemseekapp/apps/inventory-app',
      script: 'npm',
      args: 'start',
      env: {
        PORT: 3001,
        NODE_ENV: 'production'
      }
    },
    {
      name: 'tasks-app',
      cwd: '/var/www/itemseekapp/apps/tasks-app',
      script: 'npm',
      args: 'start',
      env: {
        PORT: 3002,
        NODE_ENV: 'production'
      }
    },
    {
      name: 'locations-app',
      cwd: '/var/www/itemseekapp/apps/locations-app',
      script: 'npm',
      args: 'start',
      env: {
        PORT: 3003,
        NODE_ENV: 'production'
      }
    }
  ]
};
```

Start the apps:
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## Step 5: Configure Nginx

Create nginx configuration file:
```bash
sudo nano /etc/nginx/sites-available/itemseek
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name 172.104.117.4;

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

    # Inventory app
    location /inventory {
        rewrite ^/inventory(.*)$ $1 break;
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Tasks app
    location /tasks {
        rewrite ^/tasks(.*)$ $1 break;
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Locations app
    location /locations {
        rewrite ^/locations(.*)$ $1 break;
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
sudo ln -s /etc/nginx/sites-available/itemseek /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Step 6: Update app URLs for production

You'll need to update the signup/login redirect URLs to use relative paths or the server IP:

1. In `/var/www/itemseekapp/apps/api-gateway/app/signup/page.tsx`, change:
   ```javascript
   window.location.href = 'http://localhost:3001';
   ```
   to:
   ```javascript
   window.location.href = '/inventory';
   ```

2. Do the same for login page.

## Step 7: Access your apps

- Main site: http://172.104.117.4
- Signup page: http://172.104.117.4/signup
- Login page: http://172.104.117.4/login
- Inventory app: http://172.104.117.4/inventory
- Tasks app: http://172.104.117.4/tasks
- Locations app: http://172.104.117.4/locations

## Troubleshooting

Check PM2 status:
```bash
pm2 status
pm2 logs
```

Check nginx logs:
```bash
sudo tail -f /var/log/nginx/error.log
```

Restart services:
```bash
pm2 restart all
sudo systemctl restart nginx
```