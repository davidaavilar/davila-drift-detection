provider "aws" {
  region = "us-east-1"
}

variable "stack_name" {
  default = "davila-drift-testing"
}

data "aws_region" "current" {}


# Create a VPC

resource "aws_vpc" "this" {
  cidr_block = "10.20.0.0/16"

  tags = {
    Name = "${var.stack_name}-vpc"
  }
}

# Create two Subnets: Public and Private

resource "aws_subnet" "this_public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "${data.aws_region.current.name}a"

  tags = {
    Name = "${var.stack_name}-public-subnet"
  }
}

resource "aws_subnet" "this_private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = "${data.aws_region.current.name}b"

  tags = {
    Name = "${var.stack_name}-private-subnet"
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.stack_name}-igw",
  }
}

# Create Public Route Table (to Internet Gateway)

resource "aws_route_table" "this_public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.stack_name}-public-route-table"
  }
}

resource "aws_route_table_association" "this_public" {
  subnet_id      = aws_subnet.this_public.id
  route_table_id = aws_route_table.this_public.id
}

# Create security groups to allow specific traffic

resource "aws_security_group" "web_sg" {
  name   = "${var.stack_name}-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["181.128.160.118/32","52.8.146.99/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "this" {
  instance = aws_instance.web_instance.id
  vpc      = true
}

resource "aws_instance" "web_instance" {
  ami           = "ami-0889a44b331db0194" # Amazon Linux 2023 Virginia
  instance_type = "t3.micro"
  key_name      = "ec2-default"

  subnet_id                   = aws_subnet.this_public.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  tags = {
    "Name" : "${var.stack_name}-ec2",
  }
  iam_instance_profile = aws_iam_instance_profile.this.name
}

###### EC2 INSTANCE ROLE

# IAM role that will be used for Lambda function
resource "aws_iam_role" "this" {
  name               = "${var.stack_name}-ec2-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Attach IAM Policy to IAM role for Lambda
resource "aws_iam_role_policy" "this" {
  name   = "${var.stack_name}-ec2-iam-policy"
  role   = aws_iam_role.this.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Logs",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:PutMetricFilter",
                "cloudwatch:PutMetricData"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Sid": "SNS",
            "Action": [
                "sns:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.stack_name}-ec2-instance-profile"
  role = aws_iam_role.this.id
}

output "How_to_Connect_to" {
  value = "ssh -i '/Users/davila/Documents/ec2-default.pem' ec2-user@${aws_eip.this.public_ip}"
}