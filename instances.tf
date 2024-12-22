# Ollama Server
resource "aws_instance" "ollama" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with appropriate AMI for your region
  instance_type = "t3.xlarge"  # 16GB RAM instance
  key_name      = "your-key-pair-name"  # Replace with your key pair

  vpc_security_group_ids = [aws_security_group.ollama.id]
  subnet_id              = data.aws_subnet.existing.id

  tags = {
    Name = "ollama-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e
              yum update -y
              yum install -y docker
              yum install -y aws-cli
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
              ollama pull llama2
              echo "Model pull completed at $(date)" >> /root/model_pull.log
              EOT

              chmod +x /root/pull_model.sh
              nohup /root/pull_model.sh &

              # Add cron job to check model
              echo "*/5 * * * * /usr/bin/ollama list | grep llama2 || /root/pull_model.sh" | crontab -
              EOF
}

# WebUI Server
resource "aws_instance" "webui" {
  ami           = "ami-0c55b159cbfafe1f0"  # Replace with appropriate AMI for your region
  instance_type = "t2.micro"
  key_name      = "your-key-pair-name"  # Replace with your key pair

  vpc_security_group_ids = [aws_security_group.webui.id]
  subnet_id              = data.aws_subnet.existing.id

  tags = {
    Name = "webui-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              
              OLLAMA_IP=${aws_instance.ollama.private_ip}
              docker run -d -p 80:8080 \
                -e OLLAMA_API_BASE_URL=http://$OLLAMA_IP:11434/api \
                -e PASSWORD=your_chosen_password \
                --name open-webui --restart always ghcr.io/open-webui/open-webui:main

              # Create readiness check script
              cat <<EOT > /root/check_ollama.sh
              #!/bin/bash
              until curl -s http://$OLLAMA_IP:11434/api/tags | grep llama2
              do
                echo "Waiting for Llama2 model..."
                sleep 60
              done
              echo "Llama2 model is available!"
              EOT

              chmod +x /root/check_ollama.sh
              nohup /root/check_ollama.sh &
              EOF
}