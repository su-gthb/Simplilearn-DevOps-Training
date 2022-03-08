#1. Create new Key pair
resource "aws_key_pair" "devops" {
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
    tags = {
        Name = "DevOps Public Subnet"
    }
}

#3. Create private subnet under the DevOps VPC
resource "aws_subnet" "DevOps-Private" {
    vpc_id = aws_vpc.DevOps-VPC.id
    cidr_block = "10.0.2.0/24"
    tags = {
        Name = "DevOps Private Subnet"
    }
}

#4. Create Internet Gateway for Project VPC
resource "aws_internet_gateway" "DevOps-IGW" {
    vpc_id = aws_vpc.DevOps-VPC.id
    tags = {
      Name = "DevOps-IGW"
    }  
}

#5. Deploy Host in Project VPC
resource "aws_instance" "Jenkins-Host" {
    ami = "ami-076754bea03bde973"
    instance_type = "t2.micro"
    key_name = aws_key_pair.devops.key_name
    vpc_security_group_ids  = [ "sg-022f7e53e1a5d246d" ]

    tags = { Name = "Jenkins-Host" }  
}