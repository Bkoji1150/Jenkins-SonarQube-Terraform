#!/bin/bash
sudo su
yum upgrade -y
yum update -y
yum install java-1.8.0 -y
sudo wget -O /etc/yum.repos.d/sonar.repo http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo
yum install sonar -y
service sonar start
