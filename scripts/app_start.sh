#!/bin/bash
set -e

APP_DIR="/var/www/quickjobs"
cd $APP_DIR

echo "Starting QuickJobs Node application from $APP_DIR..."
echo "Fetching environment variables from AWS Parameter Store..."

# Define SSM parameter names
MONGO_URI_PARAM="/quickjobs/prod/mongo-uri"
PORT_PARAM="/quickjobs/prod/port"
CLOUD_NAME_PARAM="/quickjobs/prod/cloud-name"
API_KEY_PARAM="/quickjobs/prod/cloud-api-key"
API_SECRET_PARAM="/quickjobs/prod/cloud-api-secret"
SECRET_KEY_PARAM="/quickjobs/prod/secret-key"
EXPIRES_IN_PARAM="/quickjobs/prod/expiration"

# Fetch values from Parameter Store
MONGO_URI=$(aws ssm get-parameter --name "$MONGO_URI_PARAM" --with-decryption --query Parameter.Value --output text) || { echo "Failed to fetch MongoDB URI"; exit 1; }
PORT=$(aws ssm get-parameter --name "$PORT_PARAM" --query Parameter.Value --output text) || { echo "Failed to fetch PORT"; exit 1; }
CLOUD_NAME=$(aws ssm get-parameter --name "$CLOUD_NAME_PARAM" --with-decryption --query Parameter.Value --output text) || { echo "Failed to fetch CLOUD_NAME"; exit 1; }
API_KEY=$(aws ssm get-parameter --name "$API_KEY_PARAM" --with-decryption --query Parameter.Value --output text) || { echo "Failed to fetch API_KEY"; exit 1; }
API_SECRET=$(aws ssm get-parameter --name "$API_SECRET_PARAM" --with-decryption --query Parameter.Value --output text) || { echo "Failed to fetch API_SECRET"; exit 1; }
SECRET_KEY=$(aws ssm get-parameter --name "$SECRET_KEY_PARAM" --with-decryption --query Parameter.Value --output text) || { echo "Failed to fetch SECRET_KEY"; exit 1; }
EXPIRES_IN=$(aws ssm get-parameter --name "$EXPIRES_IN_PARAM" --query Parameter.Value --output text) || { echo "Failed to fetch EXPIRES_IN"; exit 1; }

# Write .env file (with correct permissions)
echo "Writing .env file..."
sudo tee "$APP_DIR/.env" > /dev/null << EOF
MONGO_URI=${MONGO_URI}
PORT=${PORT}
CLOUD_NAME=${CLOUD_NAME}
API_KEY=${API_KEY}
API_SECRET=${API_SECRET}
SECRET_KEY=${SECRET_KEY}
EXPIRES_IN=${EXPIRES_IN}
EOF

# Fix ownership of .env file and project directory
sudo chown -R ec2-user:ec2-user "$APP_DIR"

echo ".env file created successfully."

# Install dependencies as ec2-user
echo "Installing dependencies..."
sudo -u ec2-user npm install

# Start app using PM2 (as ec2-user)
if ! command -v pm2 &> /dev/null; then
    echo "PM2 not found. Installing..."
    sudo -u ec2-user npm install -g pm2
fi

# Stop existing app if any
sudo -u ec2-user pm2 delete "quickjobs-app" || true

# Start the app
sudo -u ec2-user pm2 start "$APP_DIR/server.js" --name "quickjobs-app" --env production

# Setup PM2 startup
sudo pm2 startup systemd -u ec2-user --hp /home/ec2-user
sudo -u ec2-user pm2 save

echo "QuickJobs app started successfully with PM2!"
