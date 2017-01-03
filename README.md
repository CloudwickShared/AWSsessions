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

## [Create a security group with SSH access](http://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-sg.html)

`aws ec2 create-security-group --group-name tutorial-sg --description "My tutorial Security Group"`

`aws ec2 authorize-security-group-ingress --group-name tutorial-sg --protocol tcp --port 22 --cidr 0.0.0.0/0`

`aws ec2 describe-security-groups --group-names tutorial-sg`

## [Create a new SSH key Pair](http://docs.aws.amazon.com/cli/latest/userguide/cli-ec2-keypairs.html)

`aws ec2 create-key-pair --key-name TutorialKeyPair --query 'KeyMaterial' --output text > ~/.ssh/TutorialKeyPair.pem`

`chmod 0600 ~/.ssh/TutorialKeyPair.pem`

## [Create an IAM role for your instance](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

So, this machine will be our "control centre" for doing EC2 stuff, including launching other services. Let's give it a reasonably powerful (but not God-mode) IAM role.

Note: these files are part of the repository, so if you've cloned it, they're sitting in the directory ready to use.

We create a policy that allows the EC2 service to assume the role (in `ec2-trust-policy.json`)

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
```

We create a security policy in the file `PowerUser.json`:

```
{
  "Version": "2012-10-17",
  "Statement":[{
    "Effect":"Allow",
    "Action":"*",
    "Resource":"*"
  },
  {
    "Effect":"Deny",
    "Action":"iam:*",
    "Resource":"*"
  }
 ]
}
```

OK, so we've specified that EC2 can assume this role, and that the policy is to allow all actions (with one important exception).  For now, those
files are just sitting on our computer, so we need to tell AWS about them!

### Create a role

`aws iam create-role --role-name poweraccess --assume-role-policy-document file://ec2-trust-policy.json`

### Attach the policy to the role

`aws iam put-role-policy --role-name poweraccess --policy-name ManagementPermissions --policy-document file://PowerUser.json`

### Create an instance profile

`aws iam create-instance-profile --instance-profile-name poweraccess-profile`

### Attach the role to the instance profile

`aws iam add-role-to-instance-profile --instance-profile-name poweraccess-profile --role-name poweraccess`

## Add a script to execute when the instance launches

If you didn't clone the repo, you can get this from the git repository by doing:

```
wget https://raw.githubusercontent.com/derwinmcgeary/AWSsessions/master/setup-aws.sh
```

You will almost certainly want to make this a custom script which (for example) synchronises data with an S3 bucket or installs an custom components needed (for example specialist data processing code). In the end you can pass this script by using the oddly-named `--user-data` parameter when running the instance.

## Launch a new EC2 instance with the necessary Key Pair, Role,  and Security Group

`aws ec2 run-instances --image-id ami-9398d3e0 --count 1 --instance-type t2.micro --key-name TutorialKeyPair --user-data file://setup-aws.sh --iam-instance-profile Name="poweraccess-profile" --security-groups tutorial-sg`


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
When the instance has started (state is `running`), get the public IP address with

```
myec2=`aws ec2 describe-instances --filter "Name=tag:Name,Values=TutorialWorkstation" --output text --query 'Reservations[*].Instances[*].PublicIpAddress'`
```
and ssh in like this:
```
ssh -i ~/.ssh/TutorialKeyPair.pem ec2-user@$myec2
```

You might need to wait for a minute for your initial setup script to finish. At this point you have a machine which can compile code using the AWS SDK and you can launch new machines and clusters. I would advise treating this as a "disposable" computer, which means don't keep large amounts of code on it, push everything to SCM (e.g. gitlab/github), and terminate it at the end of the day. That way your build process and deploy procedures will be definitely repeatable and you won't have the "works on my computer" problem or the problem that you've tinkered with something until it works but you can't explain to someone else how you did it. It will also save you money in general if you "put away your toys" at the end of the day, but that means you need to have the discipline to script the setup and shutdown.

To terminate your instance, use `aws ec2 terminate-instances --instance-ids $instance_id`.
