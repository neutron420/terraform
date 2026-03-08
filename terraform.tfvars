aws_region   = "ap-south-1"
project_name = "my-aws-infra"
environment  = "dev"

vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
availability_zones   = ["ap-south-1a", "ap-south-1b"]

ec2_instance_type = "t3.micro"
ec2_key_name      = "my-key-pair"

ecs_container_image = "nginx:latest"
ecs_container_port  = 80
ecs_desired_count   = 2

eks_cluster_version    = "1.29"
eks_node_instance_type = "t3.medium"
eks_desired_nodes      = 2
eks_min_nodes          = 1
eks_max_nodes          = 3

# RDS
db_password = "ChangeMe!StrongP@ssw0rd123"
