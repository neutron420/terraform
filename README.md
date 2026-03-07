# ============================================================================
#  AWS Terraform Infrastructure Project
# ============================================================================
#
# FOLDER STRUCTURE:
#
#   terraform/
#   ├── main.tf              # Root module - calls all sub-modules
#   ├── variables.tf         # Input variable definitions
#   ├── outputs.tf           # Output values displayed after apply
#   ├── providers.tf         # AWS provider and Terraform settings
#   ├── backend.tf           # Remote state config (S3 + DynamoDB)
#   ├── terraform.tfvars     # Variable values (customize here)
#   ├── README.md            # This file
#   └── modules/
#       ├── vpc/             # VPC, Subnets, IGW, NAT GW, Route Tables
#       │   ├── main.tf
#       │   ├── variables.tf
#       │   └── outputs.tf
#       ├── iam/             # IAM Roles & Policies (EC2, ECS, EKS)
#       │   ├── main.tf
#       │   ├── variables.tf
#       │   └── outputs.tf
#       ├── ec2/             # EC2 Instance + Security Group
#       │   ├── main.tf
#       │   ├── variables.tf
#       │   └── outputs.tf
#       ├── alb/             # Application Load Balancer + Target Group
#       │   ├── main.tf
#       │   ├── variables.tf
#       │   └── outputs.tf
#       ├── ecs/             # ECS Cluster, Fargate Service, Auto Scaling
#       │   ├── main.tf
#       │   ├── variables.tf
#       │   └── outputs.tf
#       └── eks/             # EKS Cluster + Managed Node Group
#           ├── main.tf
#           ├── variables.tf
#           └── outputs.tf
#
# ============================================================================
# HOW TO RUN
# ============================================================================
#
# PREREQUISITES:
#   1. Install Terraform: https://developer.hashicorp.com/terraform/downloads
#   2. Install AWS CLI:   https://aws.amazon.com/cli/
#   3. Configure AWS credentials:
#        aws configure
#      (Enter your Access Key ID, Secret Access Key, region: ap-south-1)
#
# STEP 1: Initialize Terraform (downloads providers & modules)
#   terraform init
#
# STEP 2: Preview what will be created (dry run)
#   terraform plan
#
# STEP 3: Create all resources
#   terraform apply
#   (Type "yes" when prompted)
#
# STEP 4: Destroy all resources (clean up)
#   terraform destroy
#   (Type "yes" when prompted)
#
# USEFUL COMMANDS:
#   terraform fmt          # Auto-format all .tf files
#   terraform validate     # Check syntax and configuration
#   terraform output       # Show output values
#   terraform state list   # List all managed resources
#
# ============================================================================
# COST WARNING
# ============================================================================
# This project creates resources that COST MONEY:
#   - NAT Gateway:  ~$0.045/hour  (~$32/month)
#   - ALB:          ~$0.0225/hour (~$16/month)
#   - EC2 (t3.micro): ~$0.0104/hour (~$7.5/month)
#   - EKS Cluster:  ~$0.10/hour   (~$73/month)
#   - EKS Nodes:    ~$0.0416/hour each
#
# ALWAYS run "terraform destroy" when done practicing!
# ============================================================================
