# infrastructure/main.tf

variable "db_password" {
  type      = string
  sensitive = true
  default   = "MySuperSecretPassword123!"
}

resource "aws_db_instance" "example" {
  identifier = "my-database"

  engine   = "postgres"
  username = "admin"
  password = "MySuperSecretPassword123!"

  instance_class = "db.t3.micro"
}