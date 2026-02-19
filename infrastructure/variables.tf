variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo in format username/repo"
}