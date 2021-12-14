#!/bin/bash
sudo yum install java-1.8* -y
sudo yum install wget -y
sudo yum install git -y
sudo yum install epel-release java-11-openjdk-devel
sudo amazon-linux-extras install epel -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
# Start jenkins service
sudo systemctl start jenkins
# Setup Jenkins to start at boot
sudo systemctl enable jenkins
sudo yum install git -y
sudo yum install python
sudo yum install python-pip
pip install ansible
ansible --version
sudo useradd ansible
sudo echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
sudo mkdir -p /var/ansible/cw-misc-jenkins-agents-misc-ans
sudo yum -y install git ansible python3-pip
sudo pip3 install awscli boto3 botocore --upgrade --user
sudo pip install awscli boto3 botocore --upgrade --user
export PATH=/usr/local/bin:$PATH
ls -hart

#slack tokens for jenkins
# xoxb-2847899152736-2809566121911-7WrivUCeXkurOtfC2CuOupZu

# getting enviromental variable