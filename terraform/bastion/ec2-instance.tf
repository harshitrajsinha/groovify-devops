#########################
#
# IMP NOTE: This for development and that is why full access is provided, in production custom policy needs to be created as per the requirements to achieve least-privilege policy
#
#########################



# Trust policy - allows bastion host to assume the role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM Role
resource "aws_iam_role" "bastion_iam_role" {
  name               = "bastion-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

# Attach AWS-managed VPC policy
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

# Attach AWS-managed IAM policy
resource "aws_iam_role_policy_attachment" "iam_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

# Attach AWS-managed EC2 policy
resource "aws_iam_role_policy_attachment" "ec2_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Attach AWS-managed ALB policy
resource "aws_iam_role_policy_attachment" "elb_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

# Attach AWS-managed S3 policy
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach AWS-managed DocumentDB policy
resource "aws_iam_role_policy_attachment" "docdb_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDocDBFullAccess"
}

# Attach AWS-managed SSM Parameter store policy
resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# Attach AWS-managed secret manager policy
resource "aws_iam_role_policy_attachment" "secret_manager_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Attach AWS-managed ACM policy
resource "aws_iam_role_policy_attachment" "acm_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}

# Attach AWS-managed Cognito policy
resource "aws_iam_role_policy_attachment" "cognito_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

######### Some additional permissions

resource "aws_iam_policy" "additional_permissions" {
  name        = "additional-permissions-policy"
  description = "Permissions required for Terraform running from bastion host"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "CognitoCustomDomain"
        Effect = "Allow"

        Action = [
          "cognito-idp:*",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:UpdateDistribution",
          "cloudfront:TagResource",
          "cloudfront:UntagResource"
        ]

        Resource = "*"
      },
      {
        Sid    = "DocumentDBRead"
        Effect = "Allow"

        Action = [
          "rds:DescribeGlobalClusters",
          "docdb:DescribeDBClusters",
          "docdb:DescribeDBInstances",
          "docdb:DescribeDBSubnetGroups",
          "docdb:DescribeDBClusterParameterGroups",
          "docdb:DescribeDBClusterParameters",
          "docdb:DescribeDBEngineVersions",
          "docdb:ListTagsForResource"
        ]

        Resource = "*"
      },
      {
        Sid    = "DocumentDBWrite"
        Effect = "Allow"

        Action = [
          "docdb:CreateDBCluster",
          "docdb:DeleteDBCluster",
          "docdb:ModifyDBCluster",
          "docdb:CreateDBInstance",
          "docdb:DeleteDBInstance",
          "docdb:ModifyDBInstance",
          "docdb:AddTagsToResource",
          "docdb:RemoveTagsFromResource"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "addition_perm_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = aws_iam_policy.additional_permissions.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "terraform_bastion_profile" {
  name = "terraform-bastion-profile"
  role = aws_iam_role.bastion_iam_role.name
}

# ----------------------------------------------------------------------

# Key to connect to bastion host (for SSH)
resource "aws_key_pair" "spotify_bastion_key" {
  key_name   = "bastion-key"
  public_key = var.bastion_public_key
  tags = {
    Project   = var.project_tag
    Terraform = "true"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create bastion host (EC2)
resource "aws_instance" "spotify_bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.bastion_instance_type
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.terraform_bastion_profile.name
  key_name                    = aws_key_pair.spotify_bastion_key.key_name
  subnet_id                   = aws_subnet.public_subnet_spotify_project_bastion.id
  user_data_base64            = base64encode(file("./bastion-user-data.sh"))
  vpc_security_group_ids      = [aws_security_group.bastion_host_sg.id]
  tags = {
    Project   = var.project_tag
    Terraform = "true"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }
}

output "bastion_public_ip" {
  value = aws_instance.spotify_bastion.public_ip
}