# infrastructure/main.tf

variable "db_password" {
  type      = string
  sensitive = true
  default   = "MySuperSecretPassword1234!"
}

resource "aws_db_instance" "example" {
  identifier = "my-database"

  engine   = "postgres"
  username = "admin"
  password = "MySuperSecretPassword1234!"

  instance_class = "db.t3.micro"
}