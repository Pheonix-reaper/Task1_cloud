# Task1_cloud
For the Task 1 of Linux world hybrid cloud class

Task description: 
1. Create the key and security group which allow the port 80.

2. Launch EC2 instance.

3. In this Ec2 instance use the key and security group which we have created in step 1.

4. Launch one Volume (EBS) and mount that volume into /var/www/html

5. Developer have uploaded the code into git hub repo also the repo has some images.

6. Copy the git hub repo code into /var/www/html

7. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.

8 Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to update in code in /var/www/html

Optional task:

--> create snapshot of ebs volume
 
 check out my linked in post to know the details of how it could be done:https://www.linkedin.com/posts/asish-patnaik-3917a7193_aws-cloud-terraform-activity-6678022533805170688-7Ojp
