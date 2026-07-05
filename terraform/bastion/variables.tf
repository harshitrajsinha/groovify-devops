variable "project_tag" {
  description = "Project name for which these resources are created"
  type = string
  default = "spotify-project-bastion"
}

variable "project_environment" {
  description = "Project environment for which these resources are created"
  type = string
  default = "dev"
}

variable ec2_private_key_file_name{
  description = "Filename for private key created for ec2 instances"
  type = string
  default = "bastion-ec2-key.pem"
}

variable "region" {
  description = "Region in which infrastructure exists"
  type        = string
  default     = "us-east-1"
}

variable "infra_azs" {
  description = "Availability zones for bastion host"
  type        = string
  default     = "us-east-1d"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "12.8.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "12.8.101.0/24"
}

variable "ubuntu_ami_id" {
  description = "AMI of Ubuntu 24.04"
  type        = string
  default     = "ami-0f8a61b66d1accaee"
}

variable "bastion_instance_type" {
  description = "Bastion server instance type"
  type        = string
  default     = "t3a.small"
}

variable "bucket_name" {
  default = "spotify-project-terraform-state"
}