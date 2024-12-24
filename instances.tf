# To check the logs on these machines: sudo cat /var/log/cloud-init-output.log
# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a new key pair
resource "aws_key_pair" "ollama_key" {
  key_name   = "ollama-key"
  public_key = file("${path.module}/ollama-key.pub")
}

resource "aws_instance" "ollama" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "g4dn.xlarge"
  key_name      = aws_key_pair.ollama_key.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ollama.id]
  subnet_id              = data.aws_subnet.existing.id

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "ollama-server"
  }


  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update -y
              apt-get install -y docker.io
              apt-get install -y awscli
              systemctl start docker
              systemctl enable docker
              # Install Ollama
              curl https://ollama.ai/install.sh | sh
              # Configure Ollama to listen on all interfaces
              mkdir -p /etc/systemd/system/ollama.service.d
              cat <<EOT > /etc/systemd/system/ollama.service.d/override.conf
              [Service]
              Environment="OLLAMA_HOST=0.0.0.0"
              EOT
              systemctl daemon-reload
              systemctl enable ollama
              systemctl start ollama
              # Create model pull script
              cat <<EOT > /root/pull_model.sh
              #!/bin/bash
              sleep 60
              /usr/local/bin/ollama pull llama3.2:1b
              echo "Model pull completed at $(date)" >> /root/model_pull.log
              EOT
              chmod +x /root/pull_model.sh
              nohup /root/pull_model.sh &
              # Add cron job to check model
              echo "*/5 * * * * /usr/local/bin/ollama list | grep llama3.2:1b || /root/pull_model.sh" | crontab -
              EOF
}

resource "aws_instance" "webui" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.small"
  key_name      = aws_key_pair.ollama_key.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.webui.id]
  subnet_id              = data.aws_subnet.existing.id

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "webui-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io curl
              systemctl start docker
              systemctl enable docker

              OLLAMA_IP=${aws_instance.ollama.private_ip}

              # Create check script first
              cat <<EOT > /root/check_ollama.sh
              #!/bin/bash
              max_attempts=60  # Will try for 60 minutes
              attempt=1

              echo "Starting to check for Ollama server availability..."
              while true; do
                if [ \$attempt -gt \$max_attempts ]; then
                  echo "Timeout after \$max_attempts minutes waiting for Ollama"
                  exit 1
                fi

                # Check directly for model in tags endpoint
                if curl -s http://${aws_instance.ollama.private_ip}:11434/api/tags | grep -q "llama3.2:1b"; then
                    echo "Model llama3.2:1b is available!"
                    break
                else
                    echo "Attempt \$attempt: Waiting for Ollama server and model..."
                fi

                attempt=\$((attempt + 1))
                sleep 60
              done

              # Start WebUI once Ollama is ready
              docker run -d -p 80:8080 \\
                -e OLLAMA_API_BASE_URL=http://${aws_instance.ollama.private_ip}:11434 \\
                -e PASSWORD=${var.webui_password} \\
                --name open-webui --restart always \\
                ghcr.io/open-webui/open-webui:main

              echo "WebUI setup completed!"
              EOT

              chmod +x /root/check_ollama.sh
              /root/check_ollama.sh
              EOF
}