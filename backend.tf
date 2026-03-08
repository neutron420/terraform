terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-2026"
    key            = "infra/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
