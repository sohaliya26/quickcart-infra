provider "aws" {
  region = var.aws_region
}

# module "rds" {
#   source            = "./modules/rds"
#   db_name           = var.db_name
#   username          = var.db_username
#   password          = var.db_password
#   engine            = "mysql"
#   engine_version    = "8.0"
#   instance_class    = "db.t3.micro"
#   allocated_storage = 20
# }

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.s3_bucket_name
  enable_destroy = var.enable_destroy
}

# module "ecr" {
#   source          = "./modules/ecr"
#   repository_name = var.ecr_repository_name
# }

# module "ecs" {
#   source                 = "./modules/ecs"
#   cluster_name           = var.ecs_cluster_name
#   service_name           = var.ecs_service_name
#   ecr_repository_url     = "docker.io/sohaliya/laravel-app-quickcart:latest"
# }

# module "ses" {
#   source = "./modules/ses"
#   email  = var.ses_email
# }
