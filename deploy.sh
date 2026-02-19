#!/bin/bash
set -euo pipefail

APP_DIR="/opt/node-app"
AWS_REGION="ap-south-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# IMAGE_TAG can be passed via CodeDeploy env variable; fallback to 'latest'
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "===== Logging into ECR ====="
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$ECR_URL"

echo "===== Stopping old containers ====="
cd "$APP_DIR"
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose down || true
elif command -v docker >/dev/null 2>&1; then
    docker compose down || true
fi

echo "===== Pulling latest images ====="
docker pull "$ECR_URL/node-microservices-customer:$IMAGE_TAG"
docker pull "$ECR_URL/node-microservices-products:$IMAGE_TAG"
docker pull "$ECR_URL/node-microservices-shopping:$IMAGE_TAG"
docker pull "$ECR_URL/node-microservices-gateway:$IMAGE_TAG"

echo "===== Starting containers ====="
docker compose up -d

echo "===== Cleaning up unused images ====="
docker image prune -f --filter "dangling=true"

echo "===== Deployment complete ====="
