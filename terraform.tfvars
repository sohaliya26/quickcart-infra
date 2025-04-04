# AWS Region
aws_region = "us-east-1"

# RDS Configuration
db_name     = "{{DB_NAME}}"
db_username = "{{DB_USERNAME}}"
db_password = "{{DB_PASSWORD}}" # Ensure to use secrets management in production

# S3 Configuration
s3_bucket_name = "quickcart-app-bucket"


# ECR Configuration
ecr_repository_name = "quickcart-app-repo"

# ECS Configuration
ecs_cluster_name = "quickcart-cluster"
ecs_service_name = "quickcart-service"

# SES Configuration
ses_email = "mistrisulay@gmail.com"

enable_destroy = false