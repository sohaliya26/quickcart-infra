resource "aws_db_instance" "mysql" {
  identifier          = "my-mysql-db"  # Set a custom DB instance name
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_name              = var.db_name
  username             = var.username
  password             = var.password
  parameter_group_name = aws_db_parameter_group.mysql.name
  skip_final_snapshot  = true
  publicly_accessible  = true
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]  # Attach the SG
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "Security group for MySQL RDS instance"
  vpc_id      = data.aws_vpc.default.id  # Attach to the default VPC

  # Allow inbound MySQL traffic (change CIDR as needed)
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change this to restrict access (e.g., ["192.168.1.0/24"])
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_parameter_group" "mysql" {
  name   = "mysql-custom-parameters"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}
