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


## Mode;

Available Model Options: 

You can run the following models using Ollama:

### Llama 3 8B Model:
```
ollama run llama3:8b
```
Recommended EC2 Instance: 
g5.xlarge
GPU: 1 NVIDIA A10 (24GB VRAM)
Disk Space: ~16GB

### Llama 3 70B Model:
```
ollama run llama3:70b
```
Recommended EC2 Instance: 
g5.48xlarge
GPU: 8 NVIDIA A10 (192GB VRAM total)
Disk Space: ~140GB

### Llama 2 7B Chat Model:
```
ollama run llama2:7b-chat
```
Recommended EC2 Instance: 

t3.2xlarge (32GB RAM, suitable for running Llama 2 models)

### Llama 3.2 Quantized 3B Model:
```
ollama pull llama3.2:3b
```
Recommended EC2 Instance: 

g4dn.xlarge
GPU: 1 NVIDIA T4 (16GB VRAM)
Disk Space: ~10GB


## Recommendations

If you plan to run these models effectively:

- Choose Appropriate Instances: For Llama 3 8B, consider instances like g5.xlarge or g5.2xlarge that meet the VRAM requirements. For Llama 3 70B, opt for g5.48xlarge or similar multi-GPU configurations.
- Monitor Resource Usage: Always monitor your instance's resource utilization to ensure it meets the demands of the model you are running.
- Consider Quantization: If hardware limitations are significant, consider using quantized versions of the models (like Q4) which can reduce memory requirements while maintaining reasonable performance.