#!/bin/bash

# This script should prepare your EC2 instance for the AWS tutorial
# assuming instance type ami-9398d3e0

sudo yum -y update
echo "Installing developer tools..."
sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install java-1.7.0-openjdk
sudo yum install -y apache-maven
sudo yum install -y git

echo "Downloading aws java sdk..."
wget https://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip
unzip aws-java-sdk.zip
echo "Done"

ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N ""

cat ~/.ssh/id_rsa.pub

echo "Please import the above key to https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs"
