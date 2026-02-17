resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "${var.project_name}-artifacts"

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "artifact_versioning" {
  bucket = aws_s3_bucket.artifact_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_codebuild_project" "microservices_build" {
  name          = "${var.project_name}-build"
  description   = "Build all microservices docker images"
  service_role  = var.codebuild_role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true   # required for Docker build

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  build_timeout = 20
}

################################
# CODESTAR GITHUB CONNECTION
################################

resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project_name}-gc"
  provider_type = "GitHub"
}
