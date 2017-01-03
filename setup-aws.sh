#!/bin/bash

# This script should prepare your EC2 instance for the AWS tutorial
# assuming instance type ami-9398d3e0

yum -y update
yum -y install epel-release

yum install -y java-1.7.0-openjdk
yum install -y apache-maven gcc # build tools
yum install -y git emacs vim # hacking tools
yum install -y aws-kinesis-agent

pip install fake-factory numpy pytz
git clone https://github.com/kiritbasu/Fake-Apache-Log-Generator.git
