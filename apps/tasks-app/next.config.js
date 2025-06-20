/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ['@itemseek/ui', '@itemseek/api-client', '@itemseek/api-contracts'],
}

module.exports = nextConfig