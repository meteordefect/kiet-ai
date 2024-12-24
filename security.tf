# Security group for Ollama server
resource "aws_security_group" "ollama" {
  name        = "ollama-sg"
  description = "Security group for Ollama server"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ollama_from_webui" {
  type                     = "ingress"
  from_port               = 11434
  to_port                 = 11434
  protocol                = "tcp"
  source_security_group_id = aws_security_group.webui.id
  security_group_id       = aws_security_group.ollama.id
}

# Security group for WebUI server
resource "aws_security_group" "webui" {
  name        = "webui-sg"
  description = "Security group for Open WebUI server"
  vpc_id      = data.aws_vpc.existing.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
