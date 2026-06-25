#!/bin/bash

#############
# Harshit Raj Sinha
#
# This shell scripts installs necessary packages for app server on instance installation
#############

set -euo pipefail

exec > >(tee -a /tmp/user-data.log) 2>&1


sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

##############################################################
# Install git
if ! command -v git >/dev/null 2>&1; then
    sudo apt-get install -y git
fi

# Clone project repository
cd /home/ubuntu
if [ ! -d "spotify-clone-devops" ]; then
    git clone https://github.com/harshitrajsinha/spotify-clone-devops.git
fi
sudo chown -R ubuntu:ubuntu spotify-clone-devops

# Install nodejs to run servers
if ! command -v node >/dev/null 2>&1; then
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

##############################################################
# Create .env file in backend and frontend by fetching values from AWS SSM parameter store
AWS_REGION="us-east-1"
PROJECT_DIR="/home/ubuntu/spotify-clone-devops" # IN user-data, $USER corresponds to root, hence hard-coding user name

if ! command -v aws >/dev/null 2>&1; then
    sudo apt-get install -y unzip
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

BACKEND_ENV_FILE="${PROJECT_DIR}/backend/.env"
> "$BACKEND_ENV_FILE" # Truncate or create file

for name in PORT MONGODB_URI ADMIN_EMAIL NODE_ENV CLOUDINARY_API_KEY CLOUDINARY_API_SECRET CLOUDINARY_CLOUD_NAME FRONTEND_URL COGNITO_DOMAIN COGNITO_CLIENT_ID COGNITO_CLIENT_SECRET COGNITO_REDIRECT_URI COGNITO_USER_POOL_ID; do
    value=$(aws ssm get-parameter --name "/spotify/$name" --with-decryption --query "Parameter.Value" --output text --region "$AWS_REGION")
    echo "${name}=${value}" >> "$BACKEND_ENV_FILE"
done

chown ubuntu:ubuntu "$BACKEND_ENV_FILE"
chmod 600 "$BACKEND_ENV_FILE"

FRONTEND_ENV_FILE="${PROJECT_DIR}/frontend/.env"
> "$FRONTEND_ENV_FILE"

for name in VITE_BACKEND_URL VITE_COGNITO_DOMAIN VITE_COGNITO_CLIENT_ID; do
    value=$(aws ssm get-parameter --name "/spotify/$name" --with-decryption --query "Parameter.Value" --output text --region "$AWS_REGION")
    echo "${name}=${value}" >> "$FRONTEND_ENV_FILE"
done

chown ubuntu:ubuntu "$FRONTEND_ENV_FILE"
chmod 600 "$FRONTEND_ENV_FILE"
##############################################################

# Run backend and frontend service in background through systemd
cd "${PROJECT_DIR}/backend"
sudo -u ubuntu npm install

cd "${PROJECT_DIR}/frontend"
sudo -u ubuntu npm install


# Create systemd service for backend
NPM_PATH="$(command -v npm)"
 
sudo tee /etc/systemd/system/spotify-backend.service > /dev/null << EOF
[Unit]
Description=Spotify Clone Backend
After=network-online.target
Wants=network-online.target
 
[Service]
Type=simple
User=ubuntu
WorkingDirectory=${PROJECT_DIR}/backend
EnvironmentFile=${BACKEND_ENV_FILE}
ExecStart=${NPM_PATH} start
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
 
[Install]
WantedBy=multi-user.target
EOF
 
# Enable and start the backend service
sudo systemctl daemon-reload
sudo systemctl enable spotify-backend
sudo systemctl start spotify-backend

echo "Service started. Check status with: sudo systemctl status spotify-backend"
echo "View logs with: sudo journalctl -u spotify-backend -f"


# Create systemd service for frontend (change exec start in production)
NPM_PATH="$(command -v npm)"
 
sudo tee /etc/systemd/system/spotify-frontend.service > /dev/null << EOF
[Unit]
Description=Spotify Clone Frontend
After=network-online.target
Wants=network-online.target
 
[Service]
Type=simple
User=ubuntu
WorkingDirectory=${PROJECT_DIR}/frontend
EnvironmentFile=${FRONTEND_ENV_FILE}
ExecStart=${NPM_PATH} run dev
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
 
[Install]
WantedBy=multi-user.target
EOF
 
# Enable and start the backend service
sudo systemctl daemon-reload
sudo systemctl enable spotify-frontend
sudo systemctl start spotify-frontend
 
echo "Service started. Check status with: sudo systemctl status spotify-frontend"
echo "View logs with: sudo journalctl -u spotify-frontend -f"
##############################################################