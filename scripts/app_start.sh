#!/bin/bash
set -e

# Define backend directory
BACKEND_DIR="/var/www/quickjobs/backend"
cd $BACKEND_DIR

echo "Starting QuickJobs Backend Node application from $BACKEND_DIR..."
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

# Write .env file (for backend use)
echo "Writing .env file..."
sudo tee "$BACKEND_DIR/.env" > /dev/null << EOF
MONGO_URI=${MONGO_URI}
PORT=${PORT}
CLOUD_NAME=${CLOUD_NAME}
API_KEY=${API_KEY}
API_SECRET=${API_SECRET}
SECRET_KEY=${SECRET_KEY}
EXPIRES_IN=${EXPIRES_IN}
EOF

# Fix ownership of files
sudo chown -R ec2-user:ec2-user "$BACKEND_DIR"

echo ".env file created successfully."

# Install backend dependencies
echo "Installing backend dependencies..."
sudo -u ec2-user npm install

# Install PM2 globally if not installed
if ! command -v pm2 &> /dev/null; then
    echo "PM2 not found. Installing PM2 globally..."
    sudo -u ec2-user npm install -g pm2
fi

# Stop any existing PM2 process (to avoid conflicts)
sudo -u ec2-user pm2 delete "quickjobs-backend" || true

# Start the backend app with PM2
echo "Starting backend app with PM2..."
sudo -u ec2-user pm2 start "$BACKEND_DIR/index.js" --name "quickjobs-backend" --env production --watch

# Set up PM2 to restart on system reboot
sudo pm2 startup systemd -u ec2-user --hp /home/ec2-user
sudo -u ec2-user pm2 save

echo "✅ QuickJobs Backend app started successfully with PM2!"
