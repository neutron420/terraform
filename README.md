# AWS Infrastructure with Terraform

Production-grade AWS infrastructure template built with Terraform using a modular architecture. Deploys a complete environment including networking, compute, container orchestration, database, security, and monitoring — all in the `ap-south-1` (Mumbai) region.

![Terraform](https://img.shields.io/badge/Terraform-%235835CC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900?logo=amazonwebservices&logoColor=white)
![HCL](https://img.shields.io/badge/HCL-5C4EE5?logo=hashicorp&logoColor=white)

---

## Architecture Overview

### Infrastructure Diagram

```mermaid
graph TB
    subgraph AWS["AWS Cloud (ap-south-1)"]
        subgraph VPC["VPC (10.0.0.0/16)"]
            subgraph PUB["Public Subnets"]
                PUB1["Public Subnet 1<br/>10.0.1.0/24<br/>AZ: ap-south-1a"]
                PUB2["Public Subnet 2<br/>10.0.2.0/24<br/>AZ: ap-south-1b"]
            end

            subgraph PRIV["Private Subnets"]
                PRIV1["Private Subnet 1<br/>10.0.10.0/24<br/>AZ: ap-south-1a"]
                PRIV2["Private Subnet 2<br/>10.0.20.0/24<br/>AZ: ap-south-1b"]
            end

            IGW["Internet Gateway"]
            NAT["NAT Gateway"]
            ALB["Application Load Balancer"]
            EC2I["EC2 Instance<br/>t3.micro"]
            ECS["ECS Fargate<br/>SPOT"]
            EKS["EKS Cluster<br/>SPOT Nodes"]
            RDS["RDS PostgreSQL<br/>Encrypted"]
        end

        WAF["WAF v2<br/>Rate Limit + SQLi"]
        ECR["ECR Repository"]
        CW["CloudWatch<br/>Alarms + Logs"]
        SNS["SNS<br/>Email Alerts"]
        S3STATE["S3 Bucket<br/>Terraform State"]
        S3LOGS["S3 Bucket<br/>ALB Access Logs"]
        DYNAMO["DynamoDB<br/>State Lock"]
        FLOWLOG["VPC Flow Logs"]
    end

    INTERNET((Internet)) -->|HTTPS/HTTP| IGW
    IGW --> PUB1 & PUB2
    PUB1 & PUB2 --> ALB
    WAF -->|Protects| ALB
    ALB -->|Routes Traffic| ECS
    PUB1 --> EC2I
    PUB1 --> NAT
    NAT --> PRIV1 & PRIV2
    ECS --> PRIV1 & PRIV2
    EKS --> PRIV1 & PRIV2
    RDS --> PRIV1 & PRIV2
    ECS -->|Reads Images| ECR
    ECS & RDS & ALB -->|Metrics| CW
    CW -->|Triggers| SNS
    ALB -->|Logs| S3LOGS
    VPC -->|Traffic Logs| FLOWLOG
    FLOWLOG --> CW

    style AWS fill:#232F3E,stroke:#FF9900,color:#fff
    style VPC fill:#1a2332,stroke:#4B9CD3,color:#fff
    style PUB fill:#1e3a2d,stroke:#4CAF50,color:#fff
    style PRIV fill:#3a1e1e,stroke:#f44336,color:#fff
    style WAF fill:#e65100,stroke:#ff9100,color:#fff
    style ALB fill:#1565C0,stroke:#42A5F5,color:#fff
    style ECS fill:#FF9900,stroke:#FFB74D,color:#000
    style EKS fill:#326CE5,stroke:#64B5F6,color:#fff
    style RDS fill:#3b48cc,stroke:#7986CB,color:#fff
    style ECR fill:#FF9900,stroke:#FFB74D,color:#000
    style CW fill:#9C27B0,stroke:#CE93D8,color:#fff
    style SNS fill:#D32F2F,stroke:#EF9A9A,color:#fff
```

### Module Dependency Graph

Shows how Terraform modules depend on each other:

```mermaid
graph LR
    VPC["VPC Module"] --> EC2["EC2 Module"]
    VPC --> ALB["ALB Module"]
    VPC --> ECS["ECS Module"]
    VPC --> EKS["EKS Module"]
    VPC --> RDS["RDS Module"]

    IAM["IAM Module"] --> EC2
    IAM --> ECS
    IAM --> EKS

    ALB --> ECS
    ALB --> WAF["WAF Module"]
    ALB --> MON["Monitoring Module"]

    ECS --> RDS
    ECS --> MON
    EKS --> RDS
    EKS --> ARGOCD["ArgoCD Module"]

    RDS --> MON

    ECR["ECR Module"]

    style VPC fill:#4CAF50,stroke:#2E7D32,color:#fff
    style IAM fill:#FF9800,stroke:#E65100,color:#fff
    style EC2 fill:#2196F3,stroke:#1565C0,color:#fff
    style ALB fill:#1565C0,stroke:#0D47A1,color:#fff
    style ECS fill:#FF9900,stroke:#E65100,color:#fff
    style EKS fill:#326CE5,stroke:#1A237E,color:#fff
    style WAF fill:#f44336,stroke:#B71C1C,color:#fff
    style RDS fill:#3b48cc,stroke:#1A237E,color:#fff
    style ECR fill:#FF9900,stroke:#E65100,color:#fff
    style MON fill:#9C27B0,stroke:#4A148C,color:#fff
    style ARGOCD fill:#EF7B4D,stroke:#D84315,color:#fff
```

### Request Flow (How Traffic Reaches Your App)

```mermaid
sequenceDiagram
    participant User as User/Browser
    participant WAF as WAF v2
    participant ALB as Application Load Balancer
    participant TG as Target Group
    participant ECS as ECS Fargate Task
    participant RDS as RDS PostgreSQL

    User->>WAF: HTTPS Request
    Note over WAF: Check Rules:<br/>1. Common Rules<br/>2. SQL Injection<br/>3. Bad Inputs<br/>4. Rate Limit (2000/5min)

    alt Request Blocked
        WAF-->>User: 403 Forbidden
    else Request Allowed
        WAF->>ALB: Forward Request
        ALB->>TG: Route to Healthy Target
        Note over TG: Health Check: GET /<br/>Interval: 30s
        TG->>ECS: Forward to Container (Port 80)
        ECS->>RDS: Query Database (Port 5432)
        RDS-->>ECS: Return Data
        ECS-->>ALB: Response
        ALB-->>User: HTTP Response
    end

    Note over ALB: Access Logs → S3 Bucket
```

### CI/CD Pipeline Flow

```mermaid
flowchart LR
    subgraph Trigger["Trigger"]
        PUSH["Push to main"]
        PR["Pull Request"]
    end

    subgraph Lint["Job 1: Lint"]
        FMT["terraform fmt<br/>--check"]
        INIT1["terraform init<br/>--backend=false"]
        VAL["terraform validate"]
        COMMENT1["Post PR Comment<br/>Format + Validate Results"]
    end

    subgraph Security["Job 2: Security Scan"]
        TFSEC["tfsec<br/>Static Analysis"]
        CHECKOV["Checkov<br/>Policy Check"]
    end

    subgraph Plan["Job 3: Plan (PRs only)"]
        INIT2["terraform init"]
        PLAN["terraform plan<br/>--out=tfplan"]
        COMMENT2["Post Plan Output<br/>to PR Comment"]
    end

    subgraph Apply["Job 4: Apply (main only)"]
        INIT3["terraform init"]
        PLAN2["terraform plan<br/>--out=tfplan"]
        APPLY["terraform apply<br/>--auto-approve"]
    end

    PUSH & PR --> FMT --> INIT1 --> VAL --> COMMENT1
    COMMENT1 --> TFSEC --> CHECKOV

    CHECKOV -->|PR| INIT2 --> PLAN --> COMMENT2
    CHECKOV -->|Push to main| INIT3 --> PLAN2 --> APPLY

    style Trigger fill:#424242,stroke:#757575,color:#fff
    style Lint fill:#1565C0,stroke:#42A5F5,color:#fff
    style Security fill:#E65100,stroke:#FF9800,color:#fff
    style Plan fill:#2E7D32,stroke:#66BB6A,color:#fff
    style Apply fill:#B71C1C,stroke:#EF5350,color:#fff
```

### Security Layers

```mermaid
graph TB
    subgraph Layer1["Layer 1: Edge Security"]
        WAF["WAF v2<br/>Rate Limiting (2000 req/5min)<br/>SQL Injection Protection<br/>Common Attack Rules<br/>Bad Input Blocking"]
    end

    subgraph Layer2["Layer 2: Network Security"]
        SG_ALB["ALB Security Group<br/>Ports: 80, 443"]
        SG_EC2["EC2 Security Group<br/>SSH: Restricted by CIDR<br/>HTTP/HTTPS: Open"]
        SG_ECS["ECS Security Group<br/>Traffic from ALB only"]
        SG_EKS["EKS Security Group<br/>API: Restricted by CIDR<br/>Internal: Self"]
        SG_RDS["RDS Security Group<br/>Port 5432: ECS + EKS only"]
    end

    subgraph Layer3["Layer 3: Instance Security"]
        IMDS["IMDSv2 Required<br/>on EC2"]
        ENC_EBS["EBS Encryption<br/>on EC2"]
        ENC_RDS["Storage Encryption<br/>on RDS"]
        ENC_S3["AES256 Encryption<br/>on S3 Buckets"]
        DEL_PROT["Deletion Protection<br/>on Prod RDS"]
    end

    subgraph Layer4["Layer 4: Access Control"]
        IAM_EC2["EC2 Role<br/>SSM Access Only"]
        IAM_ECS["ECS Roles<br/>Execution + Task"]
        IAM_EKS["EKS Roles<br/>Cluster + Node"]
        NO_PUB["S3 Public Access<br/>Blocked"]
    end

    subgraph Layer5["Layer 5: Monitoring"]
        FLOW["VPC Flow Logs"]
        ALB_LOGS["ALB Access Logs"]
        CW_ALARMS["CloudWatch Alarms (8)"]
        SNS_ALERT["SNS Email Alerts"]
    end

    Layer1 --> Layer2 --> Layer3 --> Layer4 --> Layer5

    style Layer1 fill:#B71C1C,stroke:#EF5350,color:#fff
    style Layer2 fill:#E65100,stroke:#FF9800,color:#fff
    style Layer3 fill:#F9A825,stroke:#FDD835,color:#000
    style Layer4 fill:#1565C0,stroke:#42A5F5,color:#fff
    style Layer5 fill:#2E7D32,stroke:#66BB6A,color:#fff
```

### Auto Scaling Behavior

```mermaid
graph LR
    subgraph ECSScaling["ECS Fargate Auto Scaling"]
        direction TB
        CPU["CPU Utilization > 70%"] -->|Scale Out<br/>Cooldown: 60s| ADD["Add Tasks<br/>Max: 6"]
        CPU2["CPU Utilization < 70%"] -->|Scale In<br/>Cooldown: 300s| REM["Remove Tasks<br/>Min: 1"]
        REQ["ALB Requests > 1000/target"] -->|Scale Out<br/>Cooldown: 60s| ADD
    end

    subgraph EKSScaling["EKS Node Group Scaling"]
        direction TB
        DESIRED["Desired: 2 Nodes"]
        MIN["Min: 1 Node"]
        MAX["Max: 3 Nodes"]
        SPOT["Capacity: SPOT<br/>Instance: t3.medium"]
    end

    style ECSScaling fill:#FF9900,stroke:#E65100,color:#000
    style EKSScaling fill:#326CE5,stroke:#1A237E,color:#fff
```

---

## What Gets Created

| Module | Resources |
|--------|-----------|
| **VPC** | VPC, 2 Public Subnets, 2 Private Subnets, Internet Gateway, NAT Gateway, Elastic IP, Route Tables, VPC Flow Logs |
| **IAM** | EC2 Role + SSM + Instance Profile, ECS Execution & Task Roles, EKS Cluster & Node Roles |
| **EC2** | Hardened EC2 Instance (IMDSv2, encrypted EBS, restricted SSH, detailed monitoring) |
| **ALB** | Application Load Balancer, Target Group, HTTP Listener, Access Logs to S3 |
| **ECS** | Fargate Cluster (SPOT), Task Definition, Service, Auto Scaling (CPU + Request Count), CloudWatch Logs |
| **EKS** | EKS Cluster (full logging), Managed Node Group (SPOT), Restricted API access |
| **WAF** | Web ACL with Common Rules, SQL Injection, Bad Inputs, Rate Limiting |
| **RDS** | PostgreSQL with backups, Performance Insights, encrypted storage, deletion protection (prod) |
| **ECR** | Container registry with image scanning, encryption, lifecycle cleanup policies |
| **Monitoring** | 8 CloudWatch Alarms (ECS/RDS/ALB) + SNS email alerts |
| **ArgoCD** | Helm release of ArgoCD into the EKS cluster |

## Project Structure

```
terraform/
├── main.tf                 # Root module – calls all sub-modules
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output values after apply
├── providers.tf            # AWS provider & Terraform settings
├── backend.tf              # Remote state config (S3 + DynamoDB)
├── terraform.tfvars        # Variable values (gitignored – sensitive)
├── terraform.tfvars.example# Safe reference for terraform.tfvars
├── .gitignore              # Ignores .terraform/, *.tfstate, *.tfvars
├── .github/
│   └── workflows/
│       └── terraform.yml   # CI/CD pipeline (Lint → Security → Plan → Apply)
├── bootstrap/
│   └── main.tf             # Creates S3 bucket + DynamoDB for state backend
└── modules/
    ├── vpc/                # Networking (VPC, subnets, NAT, flow logs)
    ├── iam/                # IAM roles & policies
    ├── ec2/                # Compute instance (hardened)
    ├── alb/                # Load balancer + access logs
    ├── ecs/                # ECS Fargate (auto-scaling)
    ├── eks/                # Kubernetes (EKS)
    ├── waf/                # Web Application Firewall
    ├── rds/                # PostgreSQL database
    ├── ecr/                # Container registry
    ├── monitoring/         # CloudWatch alarms + SNS
    └── argocd/             # ArgoCD GitOps via Helm
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

### Setup Flow

```mermaid
flowchart LR
    A["1. Bootstrap<br/>S3 + DynamoDB"] --> B["2. Set Secrets<br/>TF_VAR_db_password"]
    B --> C["3. Configure<br/>terraform.tfvars"]
    C --> D["4. Init<br/>terraform init"]
    D --> E["5. Plan<br/>terraform plan"]
    E --> F["6. Apply<br/>terraform apply"]

    style A fill:#E65100,stroke:#FF9800,color:#fff
    style B fill:#B71C1C,stroke:#EF5350,color:#fff
    style C fill:#1565C0,stroke:#42A5F5,color:#fff
    style D fill:#2E7D32,stroke:#66BB6A,color:#fff
    style E fill:#F9A825,stroke:#FDD835,color:#000
    style F fill:#4CAF50,stroke:#81C784,color:#fff
```

### Step 1: Bootstrap State Backend

Create the S3 bucket and DynamoDB table for remote state:

```bash
cd bootstrap
terraform init
terraform apply
cd ..
```

### Step 2: Set Sensitive Variables

```bash
# Set your database password (never put in tfvars)
export TF_VAR_db_password="YourStrongP@ssword123!"
```

### Step 3: Configure Variables

Copy the example file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values (SSH CIDR, EKS CIDR, alert email, etc.)

### Step 4: Deploy

```bash
terraform init       # Initialize (downloads providers & modules)
terraform plan       # Preview changes
terraform apply      # Deploy everything
```

### Step 5: Clean Up

```bash
terraform destroy    # Destroy all resources
```

## Configuration

All values can be customized in `terraform.tfvars`:

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `ap-south-1` | AWS region |
| `project_name` | `my-aws-infra` | Prefix for resource names |
| `environment` | `dev` | Environment tag (dev, staging, prod) |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `ec2_instance_type` | `t3.micro` | EC2 instance size |
| `ec2_key_name` | `my-key-pair` | SSH key pair name |
| `allowed_ssh_cidr` | `[]` (disabled) | CIDRs allowed to SSH into EC2 |
| `allowed_eks_cidr` | `["10.0.0.0/16"]` | CIDRs allowed to access EKS API |
| `ecs_container_image` | `nginx:latest` | ECS Fargate container image |
| `ecs_desired_count` | `2` | Number of ECS tasks |
| `eks_cluster_version` | `1.29` | Kubernetes version |
| `eks_node_instance_type` | `t3.medium` | EKS worker node size |
| `db_password` | *(set via env var)* | RDS master password |
| `alert_email` | `""` | Email for CloudWatch alarm notifications |
| `ecr_image_tag_mutability` | `MUTABLE` | ECR tag mutability |

## Security Features

| Feature | Details |
|---------|---------|
| **SSH Restricted** | Disabled by default. Set `allowed_ssh_cidr` to enable for specific IPs |
| **EKS API Restricted** | Configurable via `allowed_eks_cidr` |
| **IMDSv2 Required** | EC2 instance requires token-based metadata access |
| **WAF Protection** | Common rules, SQL injection, bad inputs, rate limiting (2000 req/5min) |
| **Encrypted Storage** | RDS and EC2 EBS volumes encrypted at rest |
| **No Plain Text Secrets** | DB password set via environment variable, `*.tfvars` gitignored |
| **VPC Flow Logs** | All traffic logged to CloudWatch |
| **ALB Access Logs** | Request logs stored in S3 (encrypted, lifecycle managed) |
| **S3 Public Access Blocked** | All S3 buckets block public access |

## Monitoring & Alerts

8 CloudWatch alarms with SNS email notifications:

| Alarm | Metric | Threshold |
|-------|--------|-----------|
| ECS CPU High | CPUUtilization | > 80% |
| ECS Memory High | MemoryUtilization | > 80% |
| RDS CPU High | CPUUtilization | > 80% |
| RDS Low Storage | FreeStorageSpace | < 5 GB |
| RDS Connections High | DatabaseConnections | > 50 |
| ALB 5xx Errors | HTTPCode_ELB_5XX_Count | > 10/5min |
| ALB Target 5xx | HTTPCode_Target_5XX_Count | > 10/5min |
| ALB Unhealthy Hosts | UnHealthyHostCount | > 0 |

Set `alert_email` in `terraform.tfvars` to receive notifications.

## CI/CD Pipeline

GitHub Actions workflow (`.github/workflows/terraform.yml`):

| Job | Trigger | What It Does |
|-----|---------|--------------|
| **Lint** | All pushes & PRs | Format check, init, validate |
| **Security** | After lint passes | tfsec + Checkov scans |
| **Plan** | PRs only | Runs `terraform plan`, posts output to PR |
| **Apply** | Push to `main` | Runs `terraform apply` in production environment |

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `DB_PASSWORD` | RDS database password |

## Useful Commands

```bash
terraform fmt             # Auto-format .tf files
terraform validate        # Validate configuration
terraform output          # View outputs
terraform state list      # List managed resources
terraform plan -destroy   # Preview destruction
```

## Cost Estimate

> **Warning** — These resources incur charges. Always destroy when done testing.

| Resource | Hourly Cost | Monthly Estimate |
|----------|------------|-----------------|
| NAT Gateway | ~$0.045 | ~$32 |
| ALB | ~$0.0225 | ~$16 |
| EC2 (t3.micro) | ~$0.0104 | ~$7.50 |
| ECS Fargate (SPOT) | ~$0.01/task | ~$15 |
| EKS Cluster | ~$0.10 | ~$73 |
| EKS Nodes (t3.medium SPOT) | ~$0.02/each | ~$15/each |
| RDS (db.t3.micro) | ~$0.017 | ~$12 |

**Total estimate: ~$185–220/month** if left running.

```bash
# ALWAYS clean up after practicing
terraform destroy
```

---

**Built with Terraform** · Region: `ap-south-1` (Mumbai) · 11 Modules · Production-Ready Template
