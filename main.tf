# create an ec2 instance

# where to create it - provide cloud name

provider "aws" {
  # which region to use (where to create these resources)
  region = "eu-west-1"
}

# which services/resources with app_instance being my local reference to the resource
resource "aws_instance" "app_instance" {

  # what AMI (amazon machine image) ID to use
  ami = "ami-0c1c30571d2dae5c9"

  # which type of instance
  instance_type = "t3.micro"

  # that we want a public IP
  associate_public_ip_address = true

  # name the service/instance on AWS
  tags = {
    Name = "tech501-farah-terraform-app"
  }
}
