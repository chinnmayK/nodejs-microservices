#!/bin/bash

# Update system
apt update -y
apt upgrade -y

# Install required packages (including ruby, wget, git)
apt install -y docker.io docker-compose-plugin awscli ruby wget git

# Start & enable Docker
systemctl enable docker
systemctl start docker

# Allow ubuntu user to run docker
usermod -aG docker ubuntu

# Install CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Install CodeDeploy agent (Ubuntu version for ap-south-1)
cd /home/ubuntu
wget https://aws-codedeploy-ap-south-1.s3.ap-south-1.amazonaws.com/latest/install
chmod +x ./install
./install auto

systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# Create app directory
mkdir -p /opt/node-app
chown ubuntu:ubuntu /opt/node-app

echo "EC2 bootstrap complete"
