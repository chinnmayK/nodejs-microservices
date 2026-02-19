#!/bin/bash
set -e

APP_DIR="/opt/node-app"
AWS_REGION="ap-south-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

echo "Stopping old containers..."
cd $APP_DIR
docker compose down || true

echo "Pulling latest images..."
docker pull $ECR_URL/node-microservices-customer:latest
docker pull $ECR_URL/node-microservices-products:latest
docker pull $ECR_URL/node-microservices-shopping:latest
docker pull $ECR_URL/node-microservices-gateway:latest

echo "Starting containers..."
# Run docker compose up -d directly
docker compose up -d

echo "Cleaning up..."
docker image prune -f

echo "Deployment complete."