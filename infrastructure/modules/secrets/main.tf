resource "random_password" "mongo_password" {
  length  = 20
  special = true
}

resource "random_password" "rabbit_password" {
  length  = 20
  special = true
}

resource "random_password" "jwt_secret" {
  length  = 32
  special = false
}

############################################
# MongoDB Secret
############################################

resource "aws_secretsmanager_secret" "mongo_secret" {
  name = "${var.project_name}-mongo-credentials_v1"
}

resource "aws_secretsmanager_secret_version" "mongo_secret_value" {
  secret_id = aws_secretsmanager_secret.mongo_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.mongo_password.result
  })
}

############################################
# RabbitMQ Secret
############################################

resource "aws_secretsmanager_secret" "rabbit_secret" {
  name = "${var.project_name}-rabbitmq-credentials_v1"
}

resource "aws_secretsmanager_secret_version" "rabbit_secret_value" {
  secret_id = aws_secretsmanager_secret.rabbit_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.rabbit_password.result
  })
}

############################################
# JWT Secret
############################################

resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "${var.project_name}-jwt-secret_v1"
}

resource "aws_secretsmanager_secret_version" "jwt_secret_value" {
  secret_id = aws_secretsmanager_secret.jwt_secret.id

  secret_string = jsonencode({
    jwt = random_password.jwt_secret.result
  })
}


resource "aws_secretsmanager_secret" "redis_secret" {
  name = "${var.project_name}-redis_v1"
}

resource "aws_secretsmanager_secret_version" "redis_secret_value" {
  secret_id = aws_secretsmanager_secret.redis_secret.id

  secret_string = jsonencode({
    REDIS_URL = var.redis_endpoint
  })
}

