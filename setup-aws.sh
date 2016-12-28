#!/bin/bash

# This script should prepare your EC2 instance for the AWS tutorial
# assuming instance type ami-9398d3e0

sudo yum -y update
echo "Installing developer tools..."
yum -y install epel-release

# sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
# sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install java-1.7.0-openjdk
sudo yum install -y apache-maven gcc # build tools
sudo yum install -y git emacs vim # hacking tools
sudo yum install -y aws-kinesis-agent
# echo "Downloading aws java sdk..."
# wget https://sdk-for-java.amazonwebservices.com/latest/aws-java-sdk.zip
# unzip aws-java-sdk.zip
# echo "Done"

echo "Test: Downloading and compiling AWS sample app"
git clone https://github.com/awslabs/aws-java-sample.git
cd aws-java-sample
mvn package
cd ..

echo "installing requirements for Fake Log generator"
sudo pip install fake-factory numpy pytz
git clone https://github.com/kiritbasu/Fake-Apache-Log-Generator.git

echo "Run: cd Fake Apache-Log-Generator&& python apache-fake-log-gen.py -o LOG -n 0"
echo "When you want to generate infinitely long fake logs"
