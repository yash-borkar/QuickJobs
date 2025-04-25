#!/bin/bash
set -e

echo "Installing Node.js and dependencies for QuickJobs..."

# Update system packages
sudo yum update -y

# Add Node.js 16.x repo and install Node.js + npm
curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs

# Create QuickJobs app directory (ensure ec2-user has write access)
sudo mkdir -p /var/www/quickjobs
sudo chown -R ec2-user:ec2-user /var/www/quickjobs

# Install PM2 globally (for managing the Node.js app)
sudo npm install -g pm2

# Confirm installed versions
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"
echo "PM2 version: $(pm2 -v)"

echo "Environment setup completed successfully for QuickJobs."
