resource "aws_instance" "Jenkins-Host" {
    ami = "ami-076754bea03bde973"
    instance_type = "t2.micro"
    key_name = "ap-ansible"
    vpc_security_group_ids  = [ "sg-022f7e53e1a5d246d" ]

    tags = { name = "Jenkins-Host" }
  
}