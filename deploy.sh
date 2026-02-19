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
for service in customer products shopping gateway; do
    docker pull $ECR_URL/node-microservices-$service:latest
done

echo "Starting containers..."
# Using a variable to handle the flag to ensure no trailing characters interfere
DETACHED_FLAG="-d"
docker compose up $DETACHED_FLAG

echo "Cleaning up..."
docker image prune -f

echo "Deployment complete."