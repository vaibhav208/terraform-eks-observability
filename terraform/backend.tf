terraform {
  backend "s3" {
    bucket         = "vibhu-terraform-eks-observability-tf-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}