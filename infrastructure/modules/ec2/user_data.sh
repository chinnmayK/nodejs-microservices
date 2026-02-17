#!/bin/bash
apt update -y
apt upgrade -y

# Install Docker
apt install -y docker.io
systemctl enable docker
systemctl start docker

# Install Docker Compose plugin
apt install -y docker-compose-plugin

# Install AWS CLI
apt install -y awscli

# Install CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Create app directory
mkdir -p /opt/node-app
chown ubuntu:ubuntu /opt/node-app

# Allow ubuntu user to run docker
usermod -aG docker ubuntu

echo "EC2 bootstrap complete"
