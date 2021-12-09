terraform {
  required_version = ">=v0.13.2"
}



resource "aws_ssm_parameter" "cloud_agent" {

  name        = "jenkins"
  description = "Value for the aws cloudwatch agent on jenkins agents"
  type        = "String"
  tier        = "Standard"
  data_type   = "text"
  value       = file("./cloudwatch-config.json")
  tags = {
    Name = "cloudwatch_agent"
  }
}

resource "aws_instance" "jenkinsinstance" {
  count                  = var.private-subnet-count
  ami                    = "ami-002068ed284fb165b" #data.aws_ami.example.id TODO ami-002068ed284fb165b 
  instance_type          = var.instance-type
  subnet_id              = aws_subnet.fleur-public-subnet[0].id
  vpc_security_group_ids = [aws_security_group.fleur-public-security-group.id]
  key_name               = var.keypair
  user_data = base64encode(
    templatefile("${path.cwd}/template.tpl",
      {
        vars = []
    })
  )
  tags = {
    Name = var.jenkins-tags[count.index]
  }
}


resource "aws_instance" "SonarQubesinstance" {
  ami                    = "ami-002068ed284fb165b" #data.aws_ami.example.id TODO
  instance_type          = var.instance-type
  subnet_id              = aws_subnet.fleur-public-subnet[0].id
  vpc_security_group_ids = [aws_security_group.fleur-public-security-group.id]
  key_name               = var.keypair
  user_data = base64encode(
    templatefile("${path.cwd}/sonar.tpl",
      {
        vars = []
    })
  )
  tags = {
    Name = "SonarQubesinstance"
  }
}

