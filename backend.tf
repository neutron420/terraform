# IMPORTANT: Run 'cd bootstrap && terraform init && terraform apply' FIRST
# to create the S3 bucket and DynamoDB table before using this backend.
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-2026"
    key            = "infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
