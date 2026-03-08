output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.public_ip
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS Fargate service"
  value       = module.ecs.service_name
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

# ── WAF Outputs ───────────────────────────────────────────────────────────────

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL protecting the ALB"
  value       = module.waf.web_acl_arn
}

# ── RDS Outputs ───────────────────────────────────────────────────────────────

output "rds_endpoint" {
  description = "Connection endpoint of the RDS database"
  value       = module.rds.db_instance_endpoint
}

output "rds_address" {
  description = "Address of the RDS instance"
  value       = module.rds.db_instance_address
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = module.rds.db_instance_port
}
