### Work In Progress - "Learning"

# ########################################################################

# resource "aws_security_group" "sonarqube" {
#   name   = "sonarqube-sg"
#   vpc_id      = module.vpc.vpc_id

#   tags = {
#     Project     = "${var.project_name_tag}"
#     Terraform   = "true"
#     Environment = "${var.project_env_tag}"
#   }

#   ingress {
#     from_port   = 9000
#     to_port     = 9000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# ########################################################################

# resource "aws_iam_role" "ecs_execution" {
#   name = "ecsTaskExecutionRole-sonarqube"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"

#     Statement = [{
#       Effect = "Allow"

#       Principal = {
#         Service = "ecs-tasks.amazonaws.com"
#       }

#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "execution" {
#   role       = aws_iam_role.ecs_execution.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# ########################################################################

# resource "aws_ecs_cluster" "main" {
#   name = "sonarqube-cluster"
# }

# resource "aws_ecs_task_definition" "sonarqube" {

#   family                   = "sonarqube"
#   requires_compatibilities = ["FARGATE"]

#   network_mode = "awsvpc"

#   cpu    = 2048
#   memory = 4096

#   execution_role_arn = aws_iam_role.ecs_execution.arn

#   container_definitions = jsonencode([
#     {
#       name  = "sonarqube"
#       image = var.sonarqube_image
#       essential = true
#       portMappings = [
#         {
#           containerPort = 9000
#           protocol      = "tcp"
#         }
#       ]
#       environment = [
#         {
#           name  = "SONAR_WEB_JAVAOPTS"
#           value = "-Xmx1024m"
#         }
#       ]
#     }
#   ])
# }

# ####################################
# # ECS Service
# ####################################

# resource "aws_ecs_service" "sonarqube" {

#   name = "sonarqube"
#   cluster = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.sonarqube.arn
#   desired_count = 1
#   launch_type = "FARGATE"

#   network_configuration {
#     assign_public_ip = true
#     subnets = module.vpc.public_subnets
#     security_groups = [
#       aws_security_group.sonarqube.id
#     ]
#   }
# }