#!/bin/bash
set -e

echo "Installing Node.js and dependencies for QuickJobs..."

# Update system packages
yum update -y

# Add Node.js 16.x repo and install Node.js + npm
curl -sL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs

# Create QuickJobs app directory
mkdir -p /var/www/quickjobs

# Install PM2 globally
npm install -g pm2

# Confirm installed versions
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
echo "PM2 version: $(pm2 -v)"

echo "Environment setup completed successfully for QuickJobs."
