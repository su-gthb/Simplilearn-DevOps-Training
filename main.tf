locals {
  ssh_user = "ec2-user"
  key_name = "devops"
  private_key_path = "~/.ssh/devops"  
}

#1. Create new Key pair
resource "aws_key_pair" "DevOps-Key" {
    key_name = "devops"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtQVfN3Rw+LjoPpcG/RR4yuFmU4jqhTxLseAAHabVEEr8C/vLRF+w3V8fHpZfYWjj03vOenFoX7sD0Ng6v7kD75dGBGw3P1fvDfrJ3THetgrOJtXRNn3DL8bN2t4rtwhWxUAyV8DPfLGy1o0RR56puibcJQOV4fCtGWMrMrxEUM4lwNeX7gncK1nDGYl9ubX8E9YcvynIWPA6zmPMlAsw/8GUeuMiKCyGg+nDxiWTqG31u/p+hOKMSLUHPDvTX6VYxjZfeXHt/dczKDUz0QABdJx46QhAZYzzbE5EuEXCeAUTDfUR+cwtC2ytE9JiQ6ZyP5+RG4vCouZ5Tdu11Gmfsgk3OUua857YGFn2q6DDlbz1eo/SWeipCICIT9LhwmlK1XL5SiJbLA3makbsOe430Q85PIcnP8YOVDK066xPI6O/5Izbxz0YDxWBdFYsQa/gHVZ503g0Ii6Z8Rh4QrPEDqg1ULRAyyinUKRwuX/K3UkvQSV9/URoHD2npSzMxcr8= sumit@MyMintMachine"
  
}

#2. Create Project VPC named 'DevOps-VPC'
resource "aws_vpc" "DevOps-VPC" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "DevOps VPC"
        
    }
}

#3. Create public subnet under the DevOps VPC
resource "aws_subnet" "DevOps-Public" {
    vpc_id = aws_vpc.DevOps-VPC.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    tags = {
        Name = "DevOps-Public-Subnet"
    }
}

#4. Create private subnet under the DevOps VPC
resource "aws_subnet" "DevOps-Private" {
    vpc_id = aws_vpc.DevOps-VPC.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1a"
    tags = {
        Name = "DevOps-Private-Subnet"
    }
}

#5. Create Internet Gateway for Project VPC
resource "aws_internet_gateway" "DevOps-IGW" {
    vpc_id = aws_vpc.DevOps-VPC.id
    tags = {
      Name = "DevOps-IGW"
    }  
}

#6. Deploying new route table in VPC.
resource "aws_route_table" "DevOps-rt" {
  vpc_id = aws_vpc.DevOps-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DevOps-IGW.id
  }
  tags = {
    Name = "DevOps-rt"
  }
}

#7. Route table association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.DevOps-Public.id
  route_table_id = aws_route_table.DevOps-rt.id
}

#8. Deploying security groups
resource "aws_security_group" "DevOps-SG" {
  name        = "DevOps-SG"
  description = "Allow SSH,HTTP Traffic to our instance"
  vpc_id      = aws_vpc.DevOps-VPC.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  ingress {
    description      = "Enable Jenkins Port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "DevOps-SG"
  }
}

#9. Depolying network interface
resource "aws_network_interface" "DevOps-nic" {
  subnet_id       = aws_subnet.DevOps-Public.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.DevOps-SG.id]
}

#10. Deploying Elastic IP
resource "aws_eip" "Dev-Ops-eip" {
  vpc                       = true
  network_interface         = aws_network_interface.DevOps-nic.id
  associate_with_private_ip = "10.0.1.50"
  tags = {
    "Name" = "Dev-Ops-eip"
  }
}


#11. Deploy Host in Project VPC
resource "aws_instance" "Jenkins-Host" {
    ami = "ami-076754bea03bde973"
    instance_type = "t2.micro"
    availability_zone = "ap-south-1a"
    key_name = aws_key_pair.DevOps-Key.key_name
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.DevOps-nic.id
    }

    provisioner "remote-exec" {
      inline = ["echo 'wait until SSH is ready'"]

      connection {
        type = "ssh"
        user = local.ssh_user
        private_key = file(local.private_key_path)
        host = aws_instance.Jenkins-Host.public_ip        
      }  
    }
    provisioner "local-exec" {
      command = "ansible-playbook  -i ${aws_instance.Jenkins-Host.public_ip}, --private-key ${local.private_key_path} /home/sumit/Documents/Simplilearn-DevOps-Training/playbook/DevOps-tasks.yml"
      }

    tags = { Name = "Jenkins-Host" }  
}