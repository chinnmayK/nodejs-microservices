output "ec2_role_name" {
  description = "EC2 IAM role name"
  value       = aws_iam_role.ec2_role.name
}

output "instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "codebuild_role_arn" {
  description = "CodeBuild role ARN"
  value       = aws_iam_role.codebuild_role.arn
}

output "codepipeline_role_arn" {
  description = "CodePipeline role ARN"
  value       = aws_iam_role.codepipeline_role.arn
}

output "codedeploy_role_arn" {
  description = "CodeDeploy role ARN"
  value       = aws_iam_role.codedeploy_role.arn
}