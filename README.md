# Your AWS virtual workstation

This is a set up to get you productively messing around with AWS ASAP.

You will need to: have an AWS account

One slight thing which makes this not completely clockwork: you need to be aware of what region you're in. This tutorial assumes eu-west-1 because I'm eurocentric and anglophone (and a quarter Irish ;-) ).


## Access Keys

Log in here: https://console.aws.amazon.com/iam/home?region=eu-west-1#security_credential

and create and save a new access key. You only get one chance to save it, but it's not a huge tragedy if you lose it: you just have to create another one.


## Launching a new EC2 workstation instance

I prefer to use the CLI as much as possible, and the way to do that here is:

[Create a security group with SSH access](http://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-sg.html)

`aws ec2 create-security-group --group-name tutorial-sg --description "My tutorial Security Group"`

`aws ec2 authorize-security-group-ingress --group-name tutorial-sg --protocol tcp --port 22 --cidr 0.0.0.0/0`

`aws ec2 describe-security-groups --group-names tutorial-sg`

[Create a new SSH key Pair](http://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-keypairs.html)

`aws ec2 create-key-pair --key-name TutorialKeyPair --query 'KeyMaterial' --output text > TutorialKeyPair.pem`

`chmod 0600 TutorialKeyPair.pem`

Launch a new EC2 instance with the necessary Key Pair and Security Group

`aws ec2 run-instances --image-id ami-9398d3e0 --count 1 --instance-type t1.micro --key-name TutorialKeyPair --security-groups tutorial-sg`


Wait for the instance to start fully

instance_id=`aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].InstanceId'`

`aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].State.Name'`

When the instance has started

myec2=`aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].PublicIpAddress'`

ssh -i ~/.ssh/courseraproject.pem ec2-user@$myec2

And when you get there, you can set the box up for AWS development by downloading and running the setup script

`wget https://raw.githubusercontent.com/derwinmcgeary/AWSsessions/master/setup-aws.sh`

`chmod +x setup-aws.sh`
`./setup-aws.sh`