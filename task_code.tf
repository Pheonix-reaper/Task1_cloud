provider "aws" {
	profile ="Asish"
	region ="ap-south-1"
}


resource "tls_private_key" "key_task" {
  algorithm = "RSA"
}
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  key_name   = "key_task"
  public_key = tls_private_key.key_task.public_key_openssh
}

output "pem_key"{
	value=tls_private_key.key_task.private_key_pem
}


resource "aws_security_group" "task1_securitygrp" {
  name        = "task1_securitygrp"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-df9489b7"

   ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }


 ingress{
    description = "SSH"
     from_port =22
     to_port=22
      protocol ="tcp"
       cidr_blocks = ["0.0.0.0/0"]
}


ingress{
    description = "HTTP"
     from_port=80
      to_port=80
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task1_securitygrp"
  }
}

resource "aws_instance" "task1os" {
  	ami  = "ami-0447a12f28fddb066"
 	 instance_type = "t2.micro"
 	 key_name = "key_task"
  	security_groups= ["task1_securitygrp"]

  connection {
    type     = "ssh"
    user     = "ec2-user"
   private_key=tls_private_key.key_task.private_key_pem
    host     = aws_instance.task1os.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd   git -y",
      "sudo systemctl restart httpd",
      "sudo systemctl enable httpd",
    ]
  }

  tags = {
    Name = "task1os"
  }

}


resource "aws_ebs_volume" "task1_volume" {
  availability_zone = aws_instance.task1os.availability_zone
  size              = 1
  tags = {
    Name = "task1_volume"
  }
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.task1_volume.id}"
  instance_id = "${aws_instance.task1os.id}"
  force_detach = true
}


output "myos_ip" {
  value = aws_instance.task1os.public_ip
}


resource "null_resource" "nulllocal2"  {
	provisioner "local-exec" {
	    command = "echo  ${aws_instance.task1os.public_ip} > publicip.txt"
  	}
}



resource "null_resource" "nullremote3"  {

depends_on = [
    aws_volume_attachment.ebs_att,
  ]


  connection {
    type     = "ssh"
    user     = "ec2-user"
   private_key =tls_private_key.key_task.private_key_pem
    host     = aws_instance.task1os.public_ip
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4  /dev/xvdh",
      "sudo mount  /dev/xvdh  /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/Pheonix-reaper/Task1_cloud.git /var/www/html/"
    ]
  }
}



//resource "null_resource" "nulllocal1"  {


//depends_on = [
    //null_resource.nullremote3,
 // ]

//	provisioner "local-exec" {
//	    command = "chrome  ${aws_instance.task1os.public_ip}"
  //	}
//}

output  "myoutaz" {
	value = aws_instance.task1os.availability_zone
}


output "myop1"{
	value=aws_instance.task1os.id
}




output "myop2"{
	value=aws_ebs_volume.task1_volume.id
}




resource "aws_s3_bucket" "task1_bucket" {
  bucket = "task1-bucket-asish-007-s3bucket"
  acl="public-read"
 force_destroy=true

tags = {
    Name = "My bucket"
  }
}


resource "aws_s3_bucket_public_access_block" "aws_public_access" {
  bucket = "${aws_s3_bucket.task1_bucket.id}"

 block_public_acls   = false
  block_public_policy = false
}




resource "aws_cloudfront_distribution" "imgcloudfront" {
    origin {
        domain_name = "asishpatnaik_task1_bucket.s3.amazonaws.com"
        origin_id = "S3-asishpatnaik_task1_bucket" 


        custom_origin_config {
            http_port = 80
            https_port = 80
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"] 
        }
    }
       
    enabled = true


    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-asishpatnaik_task1_bucket"


        # Forward all query strings, cookies and headers
        forwarded_values {
            query_string = false
        
            cookies {
               forward = "none"
            }
        }
        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }
    # Restricts who is able to access this content
    restrictions {
        geo_restriction {
            # type of restriction, blacklist, whitelist or none
            restriction_type = "none"
        }
    }


    # SSL certificate for the service.
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}



resource "aws_ebs_snapshot" "task1_snapshot" {
  volume_id = "${aws_ebs_volume.task1_volume.id}"

  tags = {
    Name = "ebs_snap"
  }
}





