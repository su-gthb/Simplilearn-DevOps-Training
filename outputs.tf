output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.Jenkins-Host.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.Jenkins-Host.public_ip
}

output "instance_public_dns" {
   description = "Public DNS of the EC2 Instance"
   value = aws_instance.Jenkins-Host.public_dns  
}