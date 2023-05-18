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
    Name                 = "${var.stack_name}-vpc"
    git_commit           = "c473ec91004d8706f13558f28ecfb0e6ab6e1484"
    git_file             = "ec2-instance.tf"
    git_last_modified_at = "2023-05-17 14:30:17"
    git_last_modified_by = "33632789+davidaavilar@users.noreply.github.com"
    git_modifiers        = "33632789+davidaavilar"
    git_org              = "davidaavilar"
    git_repo             = "davila-drift-detection"
    yor_trace            = "1486070c-2cc5-4429-94c7-fc52606538e1"
    env                  = "dev"
  }
}

# Create two Subnets: Public and Private

resource "aws_subnet" "this_public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "${data.aws_region.current.name}a"

  tags = {
    Name                 = "${var.stack_name}-public-subnet"
    git_commit           = "c473ec91004d8706f13558f28ecfb0e6ab6e1484"
    git_file             = "ec2-instance.tf"
    git_last_modified_at = "2023-05-17 14:30:17"
    git_last_modified_by = "33632789+davidaavilar@users.noreply.github.com"
    git_modifiers        = "33632789+davidaavilar"
    git_org              = "davidaavilar"
    git_repo             = "davila-drift-detection"
    yor_trace            = "c4f28bf9-30ca-4f40-a55c-55cf135b70fe"
    env                  = "dev"
  }
}

resource "aws_subnet" "this_private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = "${data.aws_region.current.name}b"

  tags = {
    Name                 = "${var.stack_name}-private-subnet"
    git_commit           = "c473ec91004d8706f13558f28ecfb0e6ab6e1484"
    git_file             = "ec2-instance.tf"
    git_last_modified_at = "2023-05-17 14:30:17"
    git_last_modified_by = "33632789+davidaavilar@users.noreply.github.com"
    git_modifiers        = "33632789+davidaavilar"
    git_org              = "davidaavilar"
    git_repo             = "davila-drift-detection"
    yor_trace            = "9745aa8e-0e1e-4010-96a3-80b226d0b865"
    env                  = "dev"
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name                 = "${var.stack_name}-igw",
    git_commit           = "c473ec91004d8706f13558f28ecfb0e6ab6e1484"
    git_file             = "ec2-instance.tf"
    git_last_modified_at = "2023-05-17 14:30:17"
    git_last_modified_by = "33632789+davidaavilar@users.noreply.github.com"
    git_modifiers        = "33632789+davidaavilar"
    git_org              = "davidaavilar"
    git_repo             = "davila-drift-detection"
    yor_trace            = "83e04cb7-bea4-4e06-8396-ee32cd16a33e"
    env                  = "dev"
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
    Name                 = "${var.stack_name}-public-route-table"
    git_commit           = "c473ec91004d8706f13558f28ecfb0e6ab6e1484"
    git_file             = "ec2-instance.tf"
    git_last_modified_at = "2023-05-17 14:30:17"
    git_last_modified_by = "33632789+davidaavilar@users.noreply.github.com"
    git_modifiers        = "33632789+davidaavilar"
    git_org              = "davidaavilar"
    git_repo             = "davila-drift-detection"
    yor_trace            = "d93bb5b0-5626-449e-964f-be23459821a4"
    env                  = "dev"
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
    cidr_blocks = ["181.128.160.118/32", "52.8.146.99/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    git_commit           = "c473ec91004d8706f13558f28ecfb0e6ab6e1484"
    git_file             = "ec2-instance.tf"
    git_last_modified_at = "2023-05-17 14:30:17"
    git_last_modified_by = "33632789+davidaavilar@users.noreply.github.com"
    git_modifiers        = "33632789+davidaavilar"
    git_org              = "davidaavilar"
    git_repo             = "davila-drift-detection"
    yor_trace            = "d303b2e3-acdd-4845-8b38-82f37a15640b"
    env                  = "dev"
  }
}

resource "aws_eip" "this" {
  instance = aws_instance.web_instance.id
  vpc      = true
  tags = {
    git_commit           = "c473ec91004d8706f13558f28ecfb0e6ab6e1484"
    git_file             = "ec2-instance.tf"
    git_last_modified_at = "2023-05-17 14:30:17"
    git_last_modified_by = "33632789+davidaavilar@users.noreply.github.com"
    git_modifiers        = "33632789+davidaavilar"
    git_org              = "davidaavilar"
    git_repo             = "davila-drift-detection"
    yor_trace            = "4a79d5f4-9f74-4846-8577-a85760ae2ff0"
    env                  = "dev"
  }
}

resource "aws_instance" "web_instance" {
  ami           = "ami-0889a44b331db0194" # Amazon Linux 2023 Virginia
  instance_type = "t3.micro"
  key_name      = "ec2-default"

  subnet_id              = aws_subnet.this_public.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    "Name" : "${var.stack_name}-ec2",
    git_commit           = "c473ec91004d8706f13558f28ecfb0e6ab6e1484"
    git_file             = "ec2-instance.tf"
    git_last_modified_at = "2023-05-17 14:30:17"
    git_last_modified_by = "33632789+davidaavilar@users.noreply.github.com"
    git_modifiers        = "33632789+davidaavilar"
    git_org              = "davidaavilar"
    git_repo             = "davila-drift-detection"
    yor_trace            = "29351e56-0895-4c5c-a08f-376e701520b5"
    env                  = "dev"
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
  tags = {
    git_commit           = "c473ec91004d8706f13558f28ecfb0e6ab6e1484"
    git_file             = "ec2-instance.tf"
    git_last_modified_at = "2023-05-17 14:30:17"
    git_last_modified_by = "33632789+davidaavilar@users.noreply.github.com"
    git_modifiers        = "33632789+davidaavilar"
    git_org              = "davidaavilar"
    git_repo             = "davila-drift-detection"
    yor_trace            = "8e08c857-b72b-4e47-97c6-7a59f66ec4fd"
    env                  = "dev"
  }
}

# Attach IAM Policy to IAM role for Lambda
resource "aws_iam_role_policy" "this" {
  name = "${var.stack_name}-ec2-iam-policy"
  role = aws_iam_role.this.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Logs",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutMetricFilter",
          "cloudwatch:PutMetricData"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:logs:*:*:*"
      },
      {
        "Sid" : "SNS",
        "Action" : [
          "sns:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.stack_name}-ec2-instance-profile"
  role = aws_iam_role.this.id
  tags = {
    git_commit           = "c473ec91004d8706f13558f28ecfb0e6ab6e1484"
    git_file             = "ec2-instance.tf"
    git_last_modified_at = "2023-05-17 14:30:17"
    git_last_modified_by = "33632789+davidaavilar@users.noreply.github.com"
    git_modifiers        = "33632789+davidaavilar"
    git_org              = "davidaavilar"
    git_repo             = "davila-drift-detection"
    yor_trace            = "ddfa6814-26ed-4365-aa0d-b88e33dc29b3"
    env                  = "dev"
  }
}

output "How_to_Connect_to" {
  value = "ssh -i '/Users/davila/Documents/ec2-default.pem' ec2-user@${aws_eip.this.public_ip}"
}