/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ['@itemseek/api-contracts', '@itemseek/api-client', '@itemseek/db'],
}

module.exports = nextConfig