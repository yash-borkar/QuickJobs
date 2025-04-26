#!/bin/bash

echo "Running before_install.sh"

# Update system and install PM2 globally
sudo yum update -y
sudo npm install -g pm2

# Ensure previous app folder is clean
rm -rf /home/ec2-user/quickjobs
