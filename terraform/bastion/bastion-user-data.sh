#!/bin/bash

#############
# Harshit Raj Sinha
#
# This shell scripts installs necessary packages for bastion host on instance installation
#############

set -euo pipefail

exec > >(tee -a /tmp/user-data.log) 2>&1

sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install terraform
if ! command -v terraform >/dev/null 2>&1; then
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt-get update -y 
    sudo apt-get install -y terraform
fi

# Install git
if ! command -v git >/dev/null 2>&1; then
    sudo apt-get install -y git
fi

# Clone project repository that contains terraform code to be provisioned by bastion host
cd /home/ubuntu
if [ ! -d "spotify-clone-devops" ]; then
    git clone https://github.com/harshitrajsinha/spotify-clone-devops.git
fi
sudo chown -R ubuntu:ubuntu spotify-clone-devops

# Download AWS DocumentDB / RDS global CA bundle (required to access documentdb)
if [ ! -f /opt/certs/global-bundle.pem ]; then
    sudo mkdir -p /opt/certs

    sudo curl -fsSL \
      https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
      -o /opt/certs/global-bundle.pem

    sudo chmod 444 /opt/certs/global-bundle.pem
fi

# Install mongosh (mongodb shell) to access documentdb
if ! command -v mongosh >/dev/null 2>&1; then
    wget -qO- https://www.mongodb.org/static/pgp/server-8.0.asc | sudo tee /etc/apt/trusted.gpg.d/server-8.0.asc
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
    sudo apt-get update -y
    sudo apt-get install -y mongodb-mongosh
fi