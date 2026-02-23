#!/bin/bash
set -euo pipefail

APP_DIR="/opt/node-app"

echo "===== Starting Deployment ====="

########################################
# Detect AWS Region (IMDSv2 Safe)
########################################
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

AWS_REGION=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/dynamic/instance-identity/document \
  | grep region \
  | awk -F\" '{print $4}')

if [ -z "$AWS_REGION" ]; then
  echo "❌ Failed to detect AWS region"
  exit 1
fi

echo "Detected region: $AWS_REGION"

########################################
# Fetch AWS Account ID
########################################
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$ACCOUNT_ID" ]; then
  echo "❌ Failed to detect AWS account ID"
  exit 1
fi

ECR_URL="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "Account ID: $ACCOUNT_ID"

########################################
# Ensure Docker is running
########################################
if ! systemctl is-active --quiet docker; then
    echo "Docker not running. Starting Docker..."
    systemctl start docker
    sleep 5
fi

########################################
# Login to ECR
########################################
echo "Logging into ECR..."
aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$ECR_URL"

########################################
# Verify app directory
########################################
if [ ! -d "$APP_DIR" ]; then
    echo "❌ Application directory missing: $APP_DIR"
    exit 1
fi

cd "$APP_DIR"

########################################
# Fetch Secrets from AWS Secrets Manager
########################################
echo "Fetching secrets..."

MONGO_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id node-microservices-mongo-credentials_v2 \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

RABBIT_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id node-microservices-rabbitmq-credentials_v2 \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

JWT_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id node-microservices-jwt-secret_v2 \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

########################################
# Parse JSON using jq
########################################
MONGO_USERNAME=$(echo "$MONGO_SECRET" | jq -r '.username')
MONGO_PASSWORD=$(echo "$MONGO_SECRET" | jq -r '.password')

RABBITMQ_USERNAME=$(echo "$RABBIT_SECRET" | jq -r '.username')
RABBITMQ_PASSWORD=$(echo "$RABBIT_SECRET" | jq -r '.password')

APP_SECRET=$(echo "$JWT_SECRET" | jq -r '.jwt')

########################################
# Validate parsed values
########################################
if [ -z "$MONGO_USERNAME" ] || [ -z "$MONGO_PASSWORD" ] || \
   [ -z "$RABBITMQ_USERNAME" ] || [ -z "$RABBITMQ_PASSWORD" ] || \
   [ -z "$APP_SECRET" ]; then
    echo "❌ Failed to parse secrets correctly"
    exit 1
fi

########################################
# Create .env file for Docker Compose
########################################
cat > .env <<EOF
ACCOUNT_ID=$ACCOUNT_ID
AWS_REGION=$AWS_REGION
MONGO_USERNAME=$MONGO_USERNAME
MONGO_PASSWORD=$MONGO_PASSWORD
RABBITMQ_USERNAME=$RABBITMQ_USERNAME
RABBITMQ_PASSWORD=$RABBITMQ_PASSWORD
APP_SECRET=$APP_SECRET
EOF

echo ".env file generated"

########################################
# Detect Docker Compose
########################################
if docker compose version >/dev/null 2>&1; then
    DOCKER_CMD="docker compose"
elif docker-compose version >/dev/null 2>&1; then
    DOCKER_CMD="docker-compose"
else
    echo "❌ Docker Compose not found"
    exit 1
fi

echo "Using: $DOCKER_CMD"

########################################
# Stop old containers
########################################
echo "Stopping old containers..."
$DOCKER_CMD down || true

########################################
# Pull latest images
########################################
echo "Pulling images..."
docker pull "$ECR_URL/node-microservices-customer:$IMAGE_TAG"
docker pull "$ECR_URL/node-microservices-products:$IMAGE_TAG"
docker pull "$ECR_URL/node-microservices-shopping:$IMAGE_TAG"
docker pull "$ECR_URL/node-microservices-gateway:$IMAGE_TAG"

########################################
# Start containers
########################################
echo "Starting containers..."
$DOCKER_CMD up -d

########################################
# Wait for Gateway to be ready
########################################
echo "Waiting for gateway on port 8000..."

for i in {1..30}; do
  if curl -s http://localhost:8000 >/dev/null 2>&1; then
    echo "Gateway is ready."
    break
  fi
  sleep 3
done

########################################
# Restart ngrok service
########################################
echo "Starting ngrok tunnel..."
systemctl restart ngrok

########################################
# Cleanup
########################################
docker image prune -f --filter "dangling=true"

echo "===== Deployment complete ====="