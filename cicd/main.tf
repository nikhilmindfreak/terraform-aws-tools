module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-tf"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0d41e315f829ef112"] #replace your SG
  subnet_id = "subnet-0cebff8597f9b2e03" #replace your Subnet
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins.sh")
  tags = {
    Name = "jenkins-tf"
  }
}

module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-0d41e315f829ef112"]
  # convert StringList to list and get first element
  subnet_id = "subnet-0cebff8597f9b2e03"
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins-agent.sh")
  tags = {
    Name = "jenkins-agent"
  }
}

resource "aws_key_pair" "tools" {
  key_name   = "tools"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ONJth+DzeXbU3oGATxjVmoRjPepdl7sBuPzzQT2Nc sivak@BOOK-I6CR3LQ85Q"
  public_key = file("~/akhil.pub")
  # ~ means windows home directory
}

module "nexus" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "nexus"

  instance_type          = "t3.medium"
  vpc_security_group_ids = ["sg-0d41e315f829ef112"]
  # convert StringList to list and get first element
  subnet_id = "subnet-0cebff8597f9b2e03"
  ami = data.aws_ami.nexus_ami_info.id
  key_name = aws_key_pair.tools.key_name
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size = 30
    }
  ]
  tags = {
    Name = "nexus"
  }
}

# module "sonarQube" {
#   source  = "terraform-aws-modules/ec2-instance/aws"

#   name = "sonarQube"

#   instance_type          = "t3.medium"
#   vpc_security_group_ids = ["sg-0d41e315f829ef112"]
#   # convert StringList to list and get first element
#   subnet_id = "subnet-0cebff8597f9b2e03"
#   ami = data.aws_ami.nexus_ami_info.id
#   key_name = aws_key_pair.tools.key_name
#   tags = {
#     Name = "sonarQube"
#   }
# }

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip  # we gave private for practice 
      ]
      allow_overwrite = true
    },
    {
      name    = "nexus"
      type    = "A"
      ttl     = 1
      allow_overwrite = true
      records = [
        module.nexus.private_ip
      ]
      allow_overwrite = true
    }
    #  {
    #   name    = "sonarQube"
    #   type    = "A"
    #   ttl     = 1
    #   allow_overwrite = true
    #   records = [
    #     module.sonarQube.private_ip
    #   ]
    #   allow_overwrite = true
    # }
  ]

}