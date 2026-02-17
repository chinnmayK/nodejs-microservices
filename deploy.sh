#!/bin/bash

cd /opt/node-app

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=ap-south-1
PROJECT=node-microservices

echo "Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "Pulling latest images..."
docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT-customer:latest
docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT-products:latest
docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT-shopping:latest
docker pull $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$PROJECT-gateway:latest

echo "Stopping existing containers..."
docker compose down

echo "Starting updated containers..."
docker compose up -d

echo "Deployment complete"
