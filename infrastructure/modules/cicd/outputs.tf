output "artifact_bucket_name" {
  value = aws_s3_bucket.artifact_bucket.id
}

output "codestar_connection_arn" {
  value = aws_codestarconnections_connection.github.arn
}
