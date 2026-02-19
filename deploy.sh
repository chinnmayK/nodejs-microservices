#!/bin/bash
set -euo pipefail

APP_DIR="/opt/node-app"
AWS_REGION="ap-south-1"

echo "===== Fetching AWS Account ID ====="
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# IMAGE_TAG can be passed via CodeDeploy env variable; fallback to 'latest'
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "===== Logging into ECR ====="
aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$ECR_URL"

echo "===== Verifying application directory ====="
if [ ! -d "$APP_DIR" ]; then
    echo "ERROR: Application directory $APP_DIR does not exist."
    exit 1
fi

cd "$APP_DIR"

echo "===== Detecting Docker Compose command ====="
if docker compose version >/dev/null 2>&1; then
    DOCKER_CMD="docker compose"
elif docker-compose version >/dev/null 2>&1; then
    DOCKER_CMD="docker-compose"
else
    echo "ERROR: Neither 'docker compose' nor 'docker-compose' found."
    exit 1
fi

echo "Using Docker command: $DOCKER_CMD"

echo "===== Stopping old containers ====="
$DOCKER_CMD down || true

echo "===== Pulling latest images ====="
docker pull "$ECR_URL/node-microservices-customer:$IMAGE_TAG"
docker pull "$ECR_URL/node-microservices-products:$IMAGE_TAG"
docker pull "$ECR_URL/node-microservices-shopping:$IMAGE_TAG"
docker pull "$ECR_URL/node-microservices-gateway:$IMAGE_TAG"

echo "===== Starting containers ====="
$DOCKER_CMD up -d

echo "===== Cleaning up unused images ====="
docker image prune -f --filter "dangling=true"

echo "===== Deployment complete ====="
