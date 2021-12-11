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
pip3 install ansible
# Installing Docker 
yum install docker -y
service docker start
service docker status
sudo useradd dockeradmin
sudo passwd dockeradmin
sudo usermod -aG docker dockeradmin
# Installing maven
sudo su
mkdir /opt/maven
cd /opt/maven
wget https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz
tar -xvzf apache-maven-3.8.4-bin.tar.gz
cat >> ~/.bash_profile 
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.302.b08-0.amzn2.0.1.x86_64
M2_HOME=/opt/maven/apache-maven-3.8.4
M2=$M2_HOME/bin
PATH=$PATH:$HOME/bin:$M2_HOME:$M2:$JAVA_HOME 
sudo useradd ansible
sudo useradd jenkins
sudo -u jenkins mkdir /home/jenkins.ssh
# sudo echo "ansible ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
sudo mkdir -p /var/ansible/cw-misc-jenkins-agents-misc-ans
sudo yum -y install git ansible python3-pip
sudo pip3 install awscli boto3 botocore --upgrade --user
sudo pip3 install awscli boto3 botocore --upgrade --user
export PATH=/usr/local/bin:$PATH
ls -hart
