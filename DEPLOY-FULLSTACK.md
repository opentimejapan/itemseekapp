# Full Stack Deployment Guide

This guide deploys both frontend and backend to your Ubuntu server at 172.104.117.4

## Quick Deploy (One Command)

SSH into your server and run:

```bash
ssh root@172.104.117.4
```

Then execute:
```bash
curl -fsSL https://raw.githubusercontent.com/opentimejapan/itemseekapp/main/deploy-full-stack.sh | bash
```

This will:
1. Install PostgreSQL and create database
2. Clone and setup backend API
3. Clone and setup frontend apps
4. Configure nginx to route requests properly
5. Start everything with PM2

## What Gets Deployed

### Backend (Port 3100)
- Express.js API server
- PostgreSQL database
- JWT authentication
- RESTful endpoints for items, tasks, locations
- Multi-tenant support

### Frontend (Ports 3000-3003)
- API Gateway with login/signup (port 3000)
- Inventory Management app (port 3001)
- Task Management app (port 3002)
- Location Tracking app (port 3003)

### Database
- PostgreSQL with demo data
- Demo user: demo@itemseek.com / demo123
- Sample items, tasks, and locations

## Architecture

```
Internet
    |
    v
Nginx (port 80)
    |
    +---> /api/* ---------> Backend API (3100)
    |
    +---> / --------------> API Gateway (3000)
    |
    +---> /inventory -----> Inventory App (3001)
    |
    +---> /tasks ---------> Tasks App (3002)
    |
    +---> /locations -----> Locations App (3003)
```

## After Deployment

Access your apps:
- Main site: http://172.104.117.4
- Login: http://172.104.117.4/login (demo@itemseek.com / demo123)
- Inventory: http://172.104.117.4/inventory
- Tasks: http://172.104.117.4/tasks
- Locations: http://172.104.117.4/locations

## Updating

To update to latest code:
```bash
update-itemseek.sh
```

## Monitoring

```bash
# View all services
pm2 status

# View logs
pm2 logs
pm2 logs backend
pm2 logs api-gateway

# Restart services
pm2 restart all
```

## Troubleshooting

If frontend can't connect to backend:
1. Check backend is running: `pm2 status backend`
2. Check backend logs: `pm2 logs backend`
3. Test backend directly: `curl http://localhost:3100/health`

If pages show 404:
1. Check nginx: `systemctl status nginx`
2. Check nginx config: `nginx -t`
3. Restart nginx: `systemctl restart nginx`