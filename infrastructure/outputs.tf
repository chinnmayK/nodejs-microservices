output "public_ip" {
  description = "Public IP of EC2 instance"
  value       = module.ec2.public_ip
}

output "instance_name" {
  description = "EC2 instance name"
  value       = module.ec2.instance_name
}

output "redis_endpoint" {
  value = module.network.redis_endpoint
}
