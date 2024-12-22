# Ollama WebUI AWS Infrastructure

This project contains Terraform configurations to deploy Ollama with Open WebUI on AWS EC2.

## Prerequisites

- AWS account with appropriate permissions
- Terraform installed
- Existing VPC and subnet in AWS
- EC2 key pair

## Configuration

1. Update `terraform.tfvars` with your specific values:
   ```hcl
   vpc_id          = "vpc-xxxxx"
   subnet_id       = "subnet-xxxxx"
   key_name        = "your-key-pair"
   webui_password  = "your-password"
   aws_region      = "your-region"