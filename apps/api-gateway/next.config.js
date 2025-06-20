/** @type {import('next').NextConfig} */
const nextConfig = {
  transpilePackages: ['@itemseek/api-contracts', '@itemseek/db'],
}

module.exports = nextConfig