# How to Install pnpm

pnpm is a fast, disk space efficient package manager. It's NOT included with Node.js by default, but there are several ways to install it.

## Method 1: Using Corepack (Recommended for Node.js 16+)

Corepack is included with Node.js 16+ and can manage pnpm:

```bash
# Enable corepack
corepack enable

# Install and activate pnpm
corepack prepare pnpm@latest --activate

# Verify installation
pnpm --version
```

**Note**: On some systems, you might need sudo:
```bash
sudo corepack enable
```

## Method 2: Using npm

```bash
npm install -g pnpm
```

## Method 3: Using Homebrew (macOS/Linux)

```bash
brew install pnpm
```

## Method 4: Using curl (Unix/macOS)

```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

## Method 5: Using PowerShell (Windows)

```powershell
iwr https://get.pnpm.io/install.ps1 -useb | iex
```

## Quick Install for This Project

We've included an install script that handles everything:

```bash
# Run the install script
./install.sh
```

This script will:
1. Check if pnpm is installed
2. Install it if needed (trying multiple methods)
3. Run pnpm install to get all dependencies

## Verify Installation

After installing pnpm:

```bash
# Check version
pnpm --version

# Install project dependencies
pnpm install

# Start development
pnpm dev
```

## Why pnpm?

- **Fast**: Up to 2x faster than npm
- **Efficient**: Saves disk space by hard-linking packages
- **Strict**: Prevents phantom dependencies
- **Monorepo-friendly**: Built-in workspace support

## Troubleshooting

### "command not found: pnpm"
- Try opening a new terminal window
- Check your PATH: `echo $PATH`
- Try the corepack method if npm install failed

### "EACCES: permission denied"
- Don't use sudo with pnpm
- Fix npm permissions: https://docs.npmjs.com/resolving-eacces-permissions-errors

### "Unsupported URL Type workspace:*"
- You're using npm instead of pnpm
- Run: `pnpm install` (not `npm install`)