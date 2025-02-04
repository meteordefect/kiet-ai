# Private, Secure AI Chat Similar to ChatGPT Automated Deployment on AWS Infrastructure (Ollama WebUI) 

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


## Available Models and Hardware Requirements

### High-Performance Models

#### Llama 3 70B
- Command: `ollama run llama3:70b`
- Requirements:
  - Instance: g5.48xlarge
  - GPU: 8x NVIDIA A10 (192GB VRAM total)
  - Storage: ~140GB
- Use Case: Best for complex tasks requiring deep reasoning

#### Llama 3 8B
- Command: `ollama run llama3:8b`
- Requirements:
  - Instance: g5.xlarge
  - GPU: 1x NVIDIA A10 (24GB VRAM)
  - Storage: ~16GB
- Use Case: Good balance of performance and resource usage

### Mid-Range Models

#### Llama 2 7B Chat
- Command: `ollama run llama2:7b-chat`
- Requirements:
  - Instance: t3.2xlarge
  - Memory: 32GB RAM
  - Storage: ~14GB
- Use Case: Efficient for general chat applications

### Lightweight Models

#### Llama 3.2 3B
- Command: `ollama pull llama3.2:3b`
- Requirements:
  - Instance: g4dn.xlarge
  - GPU: 1x NVIDIA T4 (16GB VRAM)
  - Storage: ~10GB
- Use Case: Fast inference, suitable for production deployments

#### Llama 3.2 1B
- Command: `ollama pull llama3.2:1b`
- Requirements:
  - Instance: g4dn.medium
  - GPU: 1x NVIDIA T4 (16GB VRAM)
  - Storage: ~5GB
- Use Case: Resource-efficient, good for simple tasks


## Recommendations

If you plan to run these models effectively:

- Choose Appropriate Instances: For Llama 3 8B, consider instances like g5.xlarge or g5.2xlarge that meet the VRAM requirements. For Llama 3 70B, opt for g5.48xlarge or similar multi-GPU configurations.
- Monitor Resource Usage: Always monitor your instance's resource utilization to ensure it meets the demands of the model you are running.
- Consider Quantization: If hardware limitations are significant, consider using quantized versions of the models (like Q4) which can reduce memory requirements while maintaining reasonable performance.
