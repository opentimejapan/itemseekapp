# Installation Guide

This project uses **pnpm** (not npm) for package management.

## Install pnpm

### Option 1: Using npm (recommended)
```bash
npm install -g pnpm
```

### Option 2: Using Homebrew (macOS)
```bash
brew install pnpm
```

### Option 3: Using curl
```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

## Install Project Dependencies

Once pnpm is installed:

```bash
# Install all dependencies
pnpm install

# Start development servers
pnpm dev
```

## Why pnpm?

This project uses pnpm workspaces for:
- Faster installations
- Disk space efficiency
- Better monorepo support
- Strict dependency resolution

## Troubleshooting

### "Unsupported URL Type workspace:*"
This error occurs when using npm instead of pnpm. Make sure to use `pnpm install`.

### Command not found: pnpm
Install pnpm globally using one of the methods above.

### Permission errors
Try using sudo (not recommended) or fix npm permissions:
```bash
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
npm install -g pnpm
```