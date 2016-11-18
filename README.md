# Your AWS virtual workstation

This is a set up to get you productively messing around with AWS ASAP.

You will need to: have an AWS account

One slight thing which makes this not completely clockwork: you need to be aware of what region you're in. This tutorial assumes eu-west-1 because I'm based in the EU (and a quarter Irish ;-) ).


## Access Keys

*note: Skip this step if you already have access keys set up*
Log in here: https://console.aws.amazon.com/iam/home?region=eu-west-1#security_credential

and create and save a new access key. You only get one chance to save it, but it's not a huge tragedy if you lose it: you just have to create another one. You will need it at the end of the process.

## Setting up AWS CLI

[Instructions for various OSes here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html)

You do not have to do this: you can use the web interface to do the same steps, just make sure to choose the same AMI and instance size. It will be faster in the long run to put these steps in a script so you can run `./startWorkstation` and start working.

If you can run `aws s3 ls` withour error, then your set up is working.

## Launching a new EC2 workstation instance

I prefer to use the CLI as much as possible, and the way to do that here is:

[Create a security group with SSH access](http://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-sg.html)

`aws ec2 create-security-group --group-name tutorial-sg --description "My tutorial Security Group"`

`aws ec2 authorize-security-group-ingress --group-name tutorial-sg --protocol tcp --port 22 --cidr 0.0.0.0/0`

`aws ec2 describe-security-groups --group-names tutorial-sg`

[Create a new SSH key Pair](http://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-keypairs.html)

`aws ec2 create-key-pair --key-name TutorialKeyPair --query 'KeyMaterial' --output text > ~/.ssh/TutorialKeyPair.pem`

`chmod 0600 ~/.ssh/TutorialKeyPair.pem`

Launch a new EC2 instance with the necessary Key Pair and Security Group

`aws ec2 run-instances --image-id ami-9398d3e0 --count 1 --instance-type t2.micro --key-name TutorialKeyPair --security-groups tutorial-sg`


Wait for the instance to start fully. If this is your only instance, you can get the instance id automatically with the following command, otherwise you can see it in the output of the `run-instances` command.

```
instance_id=`aws ec2 describe-instances --filters "Name=key-name,Values=TutorialKeyPair" --output text --query 'Reservations[*].Instances[*].InstanceId'`
```

The following command waits for things to be ready:

```
aws ec2 wait instance-running --instance-ids $instance_id
```


Let's add a tag so we can find the machine again.

```
aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=TutorialWorkstation
```

Now you can query whether the instance is running or not by polling with this command.

```
aws ec2 describe-instances --filter "Name=tag:Name,Values=TutorialWorkstation" --output text --query 'Reservations[*].Instances[*].State.Name'

```
When the instance has started (state is `running`)

```
myec2=`aws ec2 describe-instances --filter "Name=tag:Name,Values=TutorialWorkstation" --output text --query 'Reservations[*].Instances[*].PublicIpAddress'`
```

```
ssh -i ~/.ssh/TutorialKeyPair.pem ec2-user@$myec2
```
And when you get there, you can set the box up for AWS development by downloading and running the setup script

`wget https://raw.githubusercontent.com/derwinmcgeary/AWSsessions/master/setup-aws.sh`

`chmod +x setup-aws.sh`

`./setup-aws.sh`

You can put the kettle on as everything updates and installs, and at the end you will be prompted to input your AWS API credentials (created at the start).

At this point you have a machine which can compile code using the AWS SDK and you can launch new machines and clusters. I would advise treating this as a "disposable" computer, which means don't keep large amounts of code on it, push everything to SCM (e.g. gitlab/github), and terminate it at the end of the day. That way your build process and deploy procedures will be definitely repeatable and you won't have the "works on my computer" problem or the problem that you've tinkered with something until it works but you can't explain to someone else how you did it. It will also save you money in general if you "put away your toys" at the end of the day, but that means you need to have the discipline to script the setup and shutdown.

To terminate your instance, use `aws ec2 terminate-instances --instance-ids $instance_id`.