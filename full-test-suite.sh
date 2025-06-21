#!/bin/bash

# Full Level Testing Suite for ItemSeek
# This script performs comprehensive tests on the server

echo "🔍 ItemSeek Full Testing Suite"
echo "=============================="
echo "Server: 172.104.117.4"
echo "Date: $(date)"
echo "=============================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test result counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $2"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}: $2"
        ((FAILED++))
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    ((WARNINGS++))
}

# ========================================
# LEVEL 1: System Requirements
# ========================================
echo "📋 LEVEL 1: System Requirements"
echo "--------------------------------"

# Test 1.1: Operating System
echo -n "1.1 Operating System: "
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "$PRETTY_NAME"
    if [[ "$ID" == "ubuntu" ]]; then
        print_result 0 "Ubuntu detected"
    else
        print_warning "Not Ubuntu, might have compatibility issues"
    fi
else
    print_result 1 "Cannot detect OS"
fi

# Test 1.2: CPU and Memory
echo -n "1.2 CPU Cores: "
cores=$(nproc)
echo "$cores"
if [ $cores -ge 1 ]; then
    print_result 0 "Sufficient CPU cores"
else
    print_result 1 "Insufficient CPU cores"
fi

echo -n "1.3 Memory: "
mem=$(free -m | awk 'NR==2{printf "%s MB (%.2f%% used)", $2, $3*100/$2 }')
echo "$mem"
mem_total=$(free -m | awk 'NR==2{print $2}')
if [ $mem_total -ge 512 ]; then
    print_result 0 "Sufficient memory"
else
    print_warning "Low memory, might affect performance"
fi

# Test 1.4: Disk Space
echo -n "1.4 Disk Space: "
disk=$(df -h / | awk 'NR==2{printf "%s (%.2f%% used)", $2, ($3/$2)*100}')
echo "$disk"
disk_percent=$(df / | awk 'NR==2{print $5}' | sed 's/%//')
if [ $disk_percent -lt 90 ]; then
    print_result 0 "Sufficient disk space"
else
    print_warning "Low disk space"
fi

echo ""

# ========================================
# LEVEL 2: Software Dependencies
# ========================================
echo "📋 LEVEL 2: Software Dependencies"
echo "--------------------------------"

# Test 2.1: Node.js
if command -v node &> /dev/null; then
    node_version=$(node -v)
    echo "2.1 Node.js: $node_version"
    major_version=$(echo $node_version | cut -d. -f1 | sed 's/v//')
    if [ $major_version -ge 18 ]; then
        print_result 0 "Node.js 18+ installed"
    else
        print_result 1 "Node.js version too old (need 18+)"
    fi
else
    print_result 1 "Node.js not installed"
fi

# Test 2.2: npm
if command -v npm &> /dev/null; then
    npm_version=$(npm -v)
    echo "2.2 npm: $npm_version"
    print_result 0 "npm installed"
else
    print_result 1 "npm not installed"
fi

# Test 2.3: pnpm
if command -v pnpm &> /dev/null; then
    pnpm_version=$(pnpm -v)
    echo "2.3 pnpm: $pnpm_version"
    print_result 0 "pnpm installed"
else
    print_result 1 "pnpm not installed"
fi

# Test 2.4: PM2
if command -v pm2 &> /dev/null; then
    pm2_version=$(pm2 -v)
    echo "2.4 PM2: $pm2_version"
    print_result 0 "PM2 installed"
else
    print_result 1 "PM2 not installed"
fi

# Test 2.5: nginx
if command -v nginx &> /dev/null; then
    nginx_version=$(nginx -v 2>&1 | awk -F'/' '{print $2}')
    echo "2.5 nginx: $nginx_version"
    print_result 0 "nginx installed"
else
    print_result 1 "nginx not installed"
fi

# Test 2.6: Git
if command -v git &> /dev/null; then
    git_version=$(git --version | awk '{print $3}')
    echo "2.6 Git: $git_version"
    print_result 0 "Git installed"
else
    print_result 1 "Git not installed"
fi

echo ""

# ========================================
# LEVEL 3: Application Files
# ========================================
echo "📋 LEVEL 3: Application Files"
echo "--------------------------------"

# Test 3.1: Application directory
if [ -d "/var/www/itemseekapp" ]; then
    print_result 0 "Application directory exists"
    
    cd /var/www/itemseekapp
    
    # Test 3.2: Git repository
    if [ -d ".git" ]; then
        current_branch=$(git branch --show-current)
        last_commit=$(git log -1 --oneline)
        echo "3.2 Git branch: $current_branch"
        echo "    Last commit: $last_commit"
        print_result 0 "Git repository valid"
    else
        print_result 1 "Not a git repository"
    fi
    
    # Test 3.3: Package files
    if [ -f "package.json" ]; then
        print_result 0 "package.json exists"
    else
        print_result 1 "package.json missing"
    fi
    
    # Test 3.4: Dependencies installed
    if [ -d "node_modules" ]; then
        module_count=$(ls node_modules | wc -l)
        echo "3.4 Node modules: $module_count packages"
        print_result 0 "Dependencies installed"
    else
        print_result 1 "Dependencies not installed"
    fi
    
    # Test 3.5: Built applications
    build_count=0
    for app in api-gateway inventory-app tasks-app locations-app; do
        if [ -d "apps/$app/.next" ]; then
            ((build_count++))
        fi
    done
    echo "3.5 Built apps: $build_count/4"
    if [ $build_count -eq 4 ]; then
        print_result 0 "All apps built"
    else
        print_result 1 "Some apps not built"
    fi
    
else
    print_result 1 "Application directory missing"
fi

echo ""

# ========================================
# LEVEL 4: Process Management (PM2)
# ========================================
echo "📋 LEVEL 4: Process Management"
echo "--------------------------------"

if command -v pm2 &> /dev/null; then
    # Test 4.1: PM2 processes
    pm2_count=$(pm2 list --json 2>/dev/null | jq '. | length' 2>/dev/null || echo 0)
    echo "4.1 PM2 processes: $pm2_count running"
    
    if [ "$pm2_count" -gt 0 ]; then
        print_result 0 "PM2 has running processes"
        
        # Test 4.2: Check each app
        for app in api-gateway inventory tasks locations; do
            if pm2 list | grep -q "$app"; then
                status=$(pm2 list --json | jq -r ".[] | select(.name==\"$app\") | .pm2_env.status" 2>/dev/null || echo "unknown")
                echo "4.2.$app: $status"
                if [ "$status" = "online" ]; then
                    print_result 0 "$app is online"
                else
                    print_result 1 "$app is not online"
                fi
            else
                print_result 1 "$app not found in PM2"
            fi
        done
    else
        print_result 1 "No PM2 processes running"
    fi
else
    print_result 1 "PM2 not available"
fi

echo ""

# ========================================
# LEVEL 5: Port Connectivity
# ========================================
echo "📋 LEVEL 5: Port Connectivity"
echo "--------------------------------"

# Test 5.1-5.4: Check each port
ports=("3000:api-gateway" "3001:inventory" "3002:tasks" "3003:locations")
for port_info in "${ports[@]}"; do
    port="${port_info%%:*}"
    app="${port_info#*:}"
    
    echo -n "5.$port - $app: "
    
    # Check if port is listening
    if ss -tuln | grep -q ":$port "; then
        echo -n "LISTENING "
        
        # Check if port responds
        response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:$port 2>/dev/null)
        echo "(HTTP $response)"
        
        if [[ "$response" =~ ^(200|301|302)$ ]]; then
            print_result 0 "Port $port responding"
        else
            print_result 1 "Port $port not responding properly"
        fi
    else
        echo "NOT LISTENING"
        print_result 1 "Port $port not listening"
    fi
done

echo ""

# ========================================
# LEVEL 6: Nginx Configuration
# ========================================
echo "📋 LEVEL 6: Nginx Configuration"
echo "--------------------------------"

# Test 6.1: Nginx service
if systemctl is-active --quiet nginx; then
    print_result 0 "Nginx service is active"
else
    print_result 1 "Nginx service is not active"
fi

# Test 6.2: Nginx config test
nginx_test=$(nginx -t 2>&1)
if [ $? -eq 0 ]; then
    print_result 0 "Nginx configuration is valid"
else
    print_result 1 "Nginx configuration has errors"
    echo "$nginx_test"
fi

# Test 6.3: ItemSeek site enabled
if [ -L "/etc/nginx/sites-enabled/itemseek" ]; then
    print_result 0 "ItemSeek site is enabled"
else
    print_result 1 "ItemSeek site not enabled"
fi

# Test 6.4: Default site disabled
if [ -e "/etc/nginx/sites-enabled/default" ]; then
    print_result 1 "Default site is still enabled (conflicts)"
else
    print_result 0 "Default site properly disabled"
fi

# Test 6.5: Port 80 listening
if ss -tuln | grep -q ":80 "; then
    print_result 0 "Nginx listening on port 80"
else
    print_result 1 "Nginx not listening on port 80"
fi

echo ""

# ========================================
# LEVEL 7: HTTP Response Tests
# ========================================
echo "📋 LEVEL 7: HTTP Response Tests"
echo "--------------------------------"

# Test 7.1: Local nginx
echo -n "7.1 http://localhost/: "
response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost/)
echo "HTTP $response"
if [ "$response" = "200" ]; then
    print_result 0 "Local nginx responds"
else
    print_result 1 "Local nginx not responding"
fi

# Test 7.2: External IP
echo -n "7.2 http://172.104.117.4/: "
response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://172.104.117.4/)
echo "HTTP $response"
if [ "$response" = "200" ]; then
    print_result 0 "External IP responds"
else
    print_result 1 "External IP not responding"
fi

# Test 7.3-7.6: Test each route
routes=("/signup" "/login" "/inventory" "/tasks" "/locations")
i=3
for route in "${routes[@]}"; do
    echo -n "7.$i http://172.104.117.4$route: "
    response=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://172.104.117.4$route)
    echo "HTTP $response"
    if [ "$response" = "200" ]; then
        print_result 0 "Route $route accessible"
    else
        print_result 1 "Route $route not accessible"
    fi
    ((i++))
done

echo ""

# ========================================
# LEVEL 8: Content Validation
# ========================================
echo "📋 LEVEL 8: Content Validation"
echo "--------------------------------"

# Test 8.1: Check for Tailwind CSS
echo -n "8.1 Tailwind CSS: "
if curl -s http://172.104.117.4/ | grep -q "tailwind\|bg-gradient\|text-blue"; then
    print_result 0 "Tailwind classes found"
else
    print_result 1 "No Tailwind classes found"
fi

# Test 8.2: Check for React
echo -n "8.2 React/Next.js: "
if curl -s http://172.104.117.4/ | grep -q "_next\|__next"; then
    print_result 0 "Next.js markers found"
else
    print_result 1 "No Next.js markers found"
fi

# Test 8.3: Check page title
echo -n "8.3 Page title: "
title=$(curl -s http://172.104.117.4/ | grep -o '<title>.*</title>' | sed 's/<[^>]*>//g')
if [ -n "$title" ]; then
    echo "$title"
    print_result 0 "Page has title"
else
    print_result 1 "No page title found"
fi

echo ""

# ========================================
# LEVEL 9: Performance Tests
# ========================================
echo "📋 LEVEL 9: Performance Tests"
echo "--------------------------------"

# Test 9.1: Response time
echo -n "9.1 Main page response time: "
time=$(curl -s -o /dev/null -w "%{time_total}" http://172.104.117.4/)
echo "${time}s"
if (( $(echo "$time < 2" | bc -l) )); then
    print_result 0 "Good response time"
else
    print_warning "Slow response time"
fi

# Test 9.2: Static asset caching
echo -n "9.2 Static asset headers: "
headers=$(curl -sI http://172.104.117.4/_next/static/test.js 2>/dev/null | grep -i "cache-control" || echo "none")
if [[ "$headers" =~ "cache" ]]; then
    print_result 0 "Caching headers present"
else
    print_warning "No caching headers"
fi

echo ""

# ========================================
# LEVEL 10: Error Logs
# ========================================
echo "📋 LEVEL 10: Recent Error Logs"
echo "--------------------------------"

# Test 10.1: PM2 errors
echo "10.1 Recent PM2 errors:"
if command -v pm2 &> /dev/null; then
    pm2 logs --lines 5 --err --nostream 2>/dev/null | tail -5 || echo "No recent errors"
fi

echo ""
echo "10.2 Recent nginx errors:"
tail -5 /var/log/nginx/error.log 2>/dev/null || echo "No access to nginx logs"

echo ""
echo "=============================="
echo "📊 TEST SUMMARY"
echo "=============================="
echo -e "${GREEN}Passed:${NC} $PASSED"
echo -e "${RED}Failed:${NC} $FAILED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    echo "Your ItemSeek installation is working correctly."
else
    echo -e "${RED}⚠️  Some tests failed.${NC}"
    echo ""
    echo "Quick fixes to try:"
    echo "1. Restart services: pm2 restart all && systemctl restart nginx"
    echo "2. Check logs: pm2 logs"
    echo "3. Rebuild apps: cd /var/www/itemseekapp && pnpm build"
    echo "4. Run fresh install: curl -fsSL https://raw.githubusercontent.com/opentimejapan/itemseekapp/main/fresh-install.sh | bash"
fi

echo ""
echo "Test completed at: $(date)"