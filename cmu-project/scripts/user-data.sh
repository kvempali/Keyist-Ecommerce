#!/bin/bash

# Update the package repository and upgrade installed packages
apt-get update
apt-get -y upgrade

# Install Docker
apt-get -y install docker.io

# Start Docker service
systemctl start docker
systemctl enable docker  # Ensure Docker starts on boot

# Install Docker Compose
apt-get -y install docker-compose

# give default user access to docker
usermod -aG docker $USER