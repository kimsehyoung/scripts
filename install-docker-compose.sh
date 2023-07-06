#!/bin/bash
# OS: Ubuntu 22.04.1 LTS
# https://docs.docker.com/engine/install/ubuntu/
set -euxo pipefail

# Search available version: apt-cache madison docker-ce
ENGINE_VERSION="5:20.10.24~3-0~ubuntu-jammy"
CONTAINERD_VERSION="1.6.21-1"
COMPOSE_VERSION="2.14.1~ubuntu-jammy"

# To use a repository over HTTPS
sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Use the following command to set up the repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install docker-ce=${ENGINE_VERSION} docker-ce-cli=${ENGINE_VERSION} containerd.io=${CONTAINERD_VERSION} docker-compose-plugin=${COMPOSE_VERSION} -y

sudo docker version
docker compose version
