# Fetch Default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch Default VPC Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-security-group"
  description = "Allow port 80 for ECS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create IAM Role for ECS Task Execution and Task Role
resource "aws_iam_role" "ecs_admin_role" {
  name = "ecs-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Attach Administrative Policy to IAM Role
resource "aws_iam_policy_attachment" "ecs_admin_attachment" {
  name       = "ecs-admin-attachment"
  roles      = [aws_iam_role.ecs_admin_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

# Create Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb-${var.cluster_name}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg-${var.cluster_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

 resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "laravel_task" {
  family                   = "laravel-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "3072"
  execution_role_arn       = aws_iam_role.ecs_admin_role.arn
  task_role_arn            = aws_iam_role.ecs_admin_role.arn

  container_definitions = jsonencode([
    {
      name         = "laravel"
      image        = "${var.ecr_repository_url}"
      portMappings = [
        {
          containerPort = 80,
          hostPort      = 80,
          protocol      = "tcp"
        }
      ]
      essential = true
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "laravel_service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.laravel_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "laravel"
    container_port   = 80
  }

  force_new_deployment = true 
  
  depends_on = [
    aws_lb_listener.app_listener,
    aws_lb_target_group.app_tg,     # Ensure target group is removed before the service
    aws_lb.app_lb 
  ]
}
