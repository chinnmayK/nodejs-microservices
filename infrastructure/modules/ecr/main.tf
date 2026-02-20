############################################################
# SERVICES LIST
############################################################

locals {
  services = [
    "customer",
    "products",
    "shopping",
    "gateway"
  ]
}

############################################################
# ECR REPOSITORIES
############################################################

resource "aws_ecr_repository" "repos" {
  for_each = toset(local.services)

  name         = "${var.project_name}-${each.key}"
  force_delete = true

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-${each.key}"
  }
}

############################################################
# LIFECYCLE POLICY
############################################################

resource "aws_ecr_lifecycle_policy" "lifecycle" {
  for_each   = aws_ecr_repository.repos
  repository = each.value.name

  policy = jsonencode({
    rules = [

      # Remove untagged images
      {
        rulePriority = 1
        description  = "Expire untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      },

      # Keep last 10 images tagged with anything
      {
        rulePriority = 2
        description  = "Keep last 10 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["latest"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}