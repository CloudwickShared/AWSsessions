# Host a website

If you have set up the AWS Workstation, now we can do something useful with it!

S3 is Amazon's block storage service. It is highly scalable and a great way to store large amounts of persistent data. For example, you can push files to S3 and then terminate instances or even example clusters when you're not actively working on them.

Let's create a simple website, by using the AWS CLI to create a bucket, enable public read access, and set a default index.html.

## Create a bucket

Bucket names must be *globally unique* so any example name here would be a failure. Replace `<bucket-name>` with your own idea. If you actually want to host your page on S3, it's best to use your domain name (e.g. data-lake.guru or similar)

```
aws s3 mb --region eu-west-1 s3://<bucket-name>
```

Assuming there were no errors, you now have a bucket.

## Configure the bucket

To add public read access we need to create a policy in a file called (say) `policy.json`:
```
{
  "Version":"2012-10-17",
  "Statement": [{
    "Sid": "Allow Public Access to All Objects",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::<bucket-name>/*"
  }
 ]
}
```

Then push it to Amazon with `aws s3api` like this:
```

aws s3api put-bucket-policy --bucket <bucket-name> --policy file://policy.json

```

## Put content up

So let's create a tiny little website.

```
mkdir <bucket-name>
cd <bucket-name>
```

Here's a minimal HTML5 page, use your favourite tool to put it into the file index.html.

```
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>It really worked!</title>
  </head>
  <body>
   <h1>It worked!</h1>
   <p>
   <a href="https://www.youtube.com/watch?v=dQw4w9WgXcQ">Don't click here</a>
   </p>
  </body>
</html>
```

Now we can move that file to the bucket, and designate it as our index page.

```
aws s3 cp index.html s3://<bucket-name>/index.html
# alternatively, you can use
# aws s3 sync . s3://<bucket-name>
# to copy all files in the current directory

aws s3 website s3://<bucket-name> --index-document index.html
```

## Test

That's it done!  You can go to the url http://&lt;bucket-name&gt;.s3-website-eu-west-1.amazonaws.com and see the page live on the public Internet.

## Teardown

S3 storage is pretty cheap (cents, not dollars), but you can remove by first removing the files, then deleting the bucket with `rb` (remove bucket).

```
aws s3 rm s3://<bucket-name>/index.html
aws s3 rb s3://<bucket-name>
aws s3 ls
```