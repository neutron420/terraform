variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "alert_email" {
  description = "Email address to receive CloudWatch alarm notifications (leave empty to skip)"
  type        = string
  default     = ""
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster for monitoring"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service for monitoring"
  type        = string
}

variable "rds_instance_identifier" {
  description = "Identifier of the RDS instance for monitoring"
  type        = string
}

variable "alb_arn_suffix" {
  description = "The ARN suffix of the ALB for CloudWatch dimensions"
  type        = string
}

variable "alb_target_group_arn_suffix" {
  description = "The ARN suffix of the ALB target group for CloudWatch dimensions"
  type        = string
}
