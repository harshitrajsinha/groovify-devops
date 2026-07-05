# Trust policy - allows EC2 to assume the role
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
resource "aws_iam_role_policy_attachment" "ec2_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "docdb_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDocDBFullAccess"
}
resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
resource "aws_iam_role_policy_attachment" "acm_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}
resource "aws_iam_role_policy_attachment" "cognito_access" {
  role       = aws_iam_role.bastion_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoPowerUser"
}

# Instance Profile
resource "aws_iam_instance_profile" "terraform_bastion_profile" {
  name = "terraform-bastion-profile"
  role = aws_iam_role.bastion_iam_role.name
}

# ----------------------------------------------------------------------

resource "aws_key_pair" "spotify_bastion_key" {
  key_name   = "bastion-key"
  public_key = file(pathexpand("~/.ssh/id_ed25519.pub"))
  tags = {
    Project     = "${var.project_tag}"
    Terraform   = "true"
    Environment = "${var.project_environment}"
  }
}

resource "aws_instance" "spotify_bastion" {
  ami                         = var.ubuntu_ami_id
  instance_type               = var.bastion_instance_type
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.terraform_bastion_profile.name
  key_name               = aws_key_pair.spotify_bastion_key.key_name
  subnet_id              = aws_subnet.public_subnet_spotify_project_bastion.id
  user_data_base64       = base64encode(file("./bastion-user-data.sh"))
  vpc_security_group_ids = [aws_security_group.bastion_host_sg.id]
  tags = {
    Project     = "${var.project_tag}"
    Terraform   = "true"
    Environment = "${var.project_environment}"
  }
}

output "bastion_public_ip" {
  value = aws_instance.spotify_bastion.public_ip
}