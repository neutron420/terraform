variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
}

variable "enable_access_logs" {
  description = "Whether to enable ALB access logs"
  type        = bool
  default     = true
}

variable "aws_account_id" {
  description = "AWS account ID (required for ALB access logs S3 bucket policy)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
