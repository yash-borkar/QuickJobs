#!/bin/bash
set -e

APP_DIR="/home/ec2-user/quickjobs"
cd $APP_DIR

echo "[QuickJobs] Starting application from $APP_DIR..."
echo "[QuickJobs] Fetching environment variables from AWS Parameter Store..."

# Define SSM parameter names
MONGO_URI_PARAM="/quickjobs/prod/mongo-uri"
PORT_PARAM="/quickjobs/prod/port"
CLOUD_NAME_PARAM="/quickjobs/prod/cloud-name"
API_KEY_PARAM="/quickjobs/prod/cloud-api-key"
API_SECRET_PARAM="/quickjobs/prod/cloud-api-secret"
SECRET_KEY_PARAM="/quickjobs/prod/secret-key"
EXPIRES_IN_PARAM="/quickjobs/prod/expiration"

# Fetch values from Parameter Store
MONGO_URI=$(aws ssm get-parameter --name "$MONGO_URI_PARAM" --with-decryption --query "Parameter.Value" --output text)
PORT=$(aws ssm get-parameter --name "$PORT_PARAM" --query "Parameter.Value" --output text)
CLOUD_NAME=$(aws ssm get-parameter --name "$CLOUD_NAME_PARAM" --with-decryption --query "Parameter.Value" --output text)
API_KEY=$(aws ssm get-parameter --name "$API_KEY_PARAM" --with-decryption --query "Parameter.Value" --output text)
API_SECRET=$(aws ssm get-parameter --name "$API_SECRET_PARAM" --with-decryption --query "Parameter.Value" --output text)
SECRET_KEY=$(aws ssm get-parameter --name "$SECRET_KEY_PARAM" --with-decryption --query "Parameter.Value" --output text)
EXPIRES_IN=$(aws ssm get-parameter --name "$EXPIRES_IN_PARAM" --query "Parameter.Value" --output text)

# Write to .env
echo "[QuickJobs] Writing environment variables to .env..."
sudo tee "$APP_DIR/.env" > /dev/null <<EOF
MONGO_URI=${MONGO_URI}
PORT=${PORT}
CLOUD_NAME=${CLOUD_NAME}
API_KEY=${API_KEY}
API_SECRET=${API_SECRET}
SECRET_KEY=${SECRET_KEY}
EXPIRES_IN=${EXPIRES_IN}
EOF

sudo chown ec2-user:ec2-user "$APP_DIR/.env"

# Install dependencies
echo "[QuickJobs] Installing backend dependencies..."
sudo -u ec2-user npm install

# Check and install PM2
if ! command -v pm2 &> /dev/null; then
  echo "[QuickJobs] PM2 not found. Installing globally..."
  sudo -u ec2-user npm install -g pm2
fi

# Stop existing PM2 process (if any)
echo "[QuickJobs] Restarting app using PM2..."
sudo -u ec2-user pm2 delete "quickjobs-app" || true

# Start the application
sudo -u ec2-user pm2 start index.js --name "quickjobs-app" --env production

# Enable PM2 startup on reboot
sudo pm2 startup systemd -u ec2-user --hp /home/ec2-user
sudo -u ec2-user pm2 save

echo "[QuickJobs] App successfully started using PM2!"
