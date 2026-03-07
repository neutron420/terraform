# AWS Infrastructure with Terraform

Production-grade AWS infrastructure provisioned using Terraform with a modular architecture. Deploys a complete environment including networking, compute, container orchestration, and load balancing — all in the `ap-south-1` (Mumbai) region.

![Terraform](https://img.shields.io/badge/Terraform-%235835CC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900?logo=amazonwebservices&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-5C4EE5?logo=hashicorp&logoColor=white)

---

## Architecture Overview

```
                          ┌─────────────────────────────────────────────┐
                          │               AWS Cloud (ap-south-1)        │
                          │                                             │
                          │  ┌───────────────────────────────────────┐  │
                          │  │          VPC (10.0.0.0/16)            │  │
                          │  │                                       │  │
          Internet ──────►│  │  ┌─────────┐        ┌─────────┐      │  │
                          │  │  │ Public  │        │ Public  │      │  │
                          │  │  │Subnet-1 │        │Subnet-2 │      │  │
                          │  │  │ (AZ-1a) │        │ (AZ-1b) │      │  │
                          │  │  └────┬────┘        └────┬────┘      │  │
                          │  │       │    ┌────────┐    │           │  │
                          │  │       └───►│  ALB   │◄───┘           │  │
                          │  │            └───┬────┘                │  │
                          │  │           NAT GW │                    │  │
                          │  │  ┌─────────┐    │   ┌─────────┐      │  │
                          │  │  │ Private │    ▼   │ Private │      │  │
                          │  │  │Subnet-1 │  ECS   │Subnet-2 │      │  │
                          │  │  │ (AZ-1a) │ Fargate│ (AZ-1b) │      │  │
                          │  │  │   EKS   │        │   EKS   │      │  │
                          │  │  └─────────┘        └─────────┘      │  │
                          │  └───────────────────────────────────────┘  │
                          └─────────────────────────────────────────────┘
```

## What Gets Created

| Module | Resources |
|--------|-----------|
| **VPC** | VPC, 2 Public Subnets, 2 Private Subnets, Internet Gateway, NAT Gateway, Elastic IP, Route Tables |
| **IAM** | EC2 Role + Instance Profile, ECS Execution & Task Roles, EKS Cluster & Node Roles, Policy Attachments |
| **EC2** | Security Group (SSH/HTTP/HTTPS), EC2 Instance (Amazon Linux, Apache httpd) |
| **ALB** | Application Load Balancer, Target Group (IP type), HTTP Listener, ALB Security Group |
| **ECS** | Fargate Cluster, Task Definition (nginx), Service, Auto Scaling (CPU + Request Count) |
| **EKS** | EKS Cluster (full logging), Managed Node Group (ON_DEMAND), Cluster Security Group |

## Project Structure

```
terraform/
├── main.tf                 # Root module – calls all sub-modules
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output values after apply
├── providers.tf            # AWS provider & Terraform settings
├── backend.tf              # Remote state config (S3 + DynamoDB)
├── terraform.tfvars        # Variable values (customize here)
├── .gitignore              # Ignores .terraform/, *.tfstate, etc.
└── modules/
    ├── vpc/                # Networking layer
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/                # IAM Roles & Policies
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/                # Compute instance
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── alb/                # Load balancer
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ecs/                # Container orchestration (Fargate)
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── eks/                # Kubernetes (EKS)
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with valid credentials
- An existing EC2 Key Pair in `ap-south-1` (update `ec2_key_name` in `terraform.tfvars`)

```bash
aws configure
# Access Key ID:     <your-key>
# Secret Access Key: <your-secret>
# Default Region:    ap-south-1
```

## Quick Start

```bash
# 1. Initialize (downloads providers & modules)
terraform init

# 2. Preview changes
terraform plan

# 3. Deploy everything
terraform apply

# 4. Clean up when done
terraform destroy
```

## Configuration

All values can be customized in `terraform.tfvars`:

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `ap-south-1` | AWS region |
| `project_name` | `my-aws-infra` | Prefix for resource names |
| `environment` | `dev` | Environment tag |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `ec2_instance_type` | `t3.micro` | EC2 instance size |
| `ec2_key_name` | `my-key-pair` | SSH key pair name |
| `ecs_container_image` | `nginx:latest` | ECS Fargate container image |
| `ecs_desired_count` | `2` | Number of ECS tasks |
| `eks_cluster_version` | `1.29` | Kubernetes version |
| `eks_node_instance_type` | `t3.medium` | EKS worker node size |

## Useful Commands

```bash
terraform fmt             # Auto-format .tf files
terraform validate        # Validate configuration
terraform output          # View outputs
terraform state list      # List managed resources
terraform plan -destroy   # Preview destruction
```

## Cost Estimate

> **Warning** — These resources incur charges. Always destroy when done.

| Resource | Hourly Cost | Monthly Estimate |
|----------|------------|-----------------|
| NAT Gateway | ~$0.045 | ~$32 |
| ALB | ~$0.0225 | ~$16 |
| EC2 (t3.micro) | ~$0.0104 | ~$7.50 |
| EKS Cluster | ~$0.10 | ~$73 |
| EKS Nodes (t3.medium) | ~$0.0416/each | ~$30/each |

**Total estimate: ~$160–190/month** if left running.

```bash
# ALWAYS clean up after practicing
terraform destroy
```

## Remote State (Optional)

The project includes a pre-configured S3 + DynamoDB backend in `backend.tf` (currently commented out). To enable:

1. Create an S3 bucket and DynamoDB table in AWS
2. Uncomment the backend block in `backend.tf`
3. Run `terraform init` to migrate state

---

**Built with Terraform** · Region: `ap-south-1` (Mumbai)
