output "ollama_public_ip" {
  value = aws_instance.ollama.public_ip
}

output "webui_public_ip" {
  value = aws_instance.webui.public_ip
}

output "ollama_private_ip" {
  value = aws_instance.ollama.private_ip
}