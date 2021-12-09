# EC2.tf

/*
data "aws_ami" "example" {
  most_recent      = true
  owners           = ["309956199498"]

  filter {
    name   = "name"
    values = var.datavalue
  }
}*/


resource "aws_instance" "jenkinsinstance" {
  count                  = var.private-subnet-count
  ami                    = "ami-002068ed284fb165b" #data.aws_ami.example.id TODO
  instance_type          = var.instance-type
  subnet_id              = aws_subnet.fleur-public-subnet[0].id
  vpc_security_group_ids = [aws_security_group.fleur-public-security-group.id]
  key_name               = var.keypair
  user_data              = <<EOF
#!/bin/bash
cd /home/ec2-user
sudo yum install java-1.8* -y
sudo yum install wget -y
sudo yum install git -y
sudo yum install epel-release java-11-openjdk-devel
sudo amazon-linux-extras install epel
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
# Start jenkins service
sudo systemctl start jenkins
# Setup Jenkins to start at boot
sudo systemctl enable jenkins
cd /home/ec2-user
ls -hart
EOF
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
  user_data              = <<EOF
#!/bin/bash
cd /home/ec2-user
sudo yum install java-1.8* -y
sudo yum install wget -y
sudo yum install git -y
sudo yum install epel-release java-11-openjdk-devel
sudo amazon-linux-extras install epel
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
# Start jenkins service
sudo systemctl start jenkins
# Setup Jenkins to start at boot
sudo systemctl enable jenkins
cd /home/ec2-user
ls -hart
EOF
  tags = {
    Name = "SonarQubesinstance"
  }
}

