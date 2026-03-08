variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "aws_account_id" {
  description = "AWS account ID (used for ALB access logs bucket policy)"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Name of the project (used for tagging and naming resources)"
  type        = string
  default     = "my-aws-infra"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "Name of the SSH key pair for EC2 access (must exist in AWS)"
  type        = string
  default     = "my-key-pair"
}

variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed to SSH into EC2 (empty list disables SSH, use SSM instead)"
  type        = list(string)
  default     = []
}

variable "allowed_eks_cidr" {
  description = "CIDR blocks allowed to access EKS API (default: open, restrict for production)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ecs_container_image" {
  description = "Docker image for the ECS Fargate task"
  type        = string
  default     = "nginx:latest"
}

variable "ecs_container_port" {
  description = "Port exposed by the ECS container"
  type        = number
  default     = 80
}

variable "ecs_desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 2
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_desired_nodes" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "eks_min_nodes" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "eks_max_nodes" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 3
}

variable "db_password" {
  description = "Password for the RDS master DB user (set via TF_VAR_db_password env variable)"
  type        = string
  sensitive   = true
}

variable "ecr_image_tag_mutability" {
  description = "ECR image tag mutability (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications (leave empty to skip)"
  type        = string
  default     = ""
}
