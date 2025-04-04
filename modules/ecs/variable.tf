variable "cluster_name" {
  description = "ECS Cluster name"
  type        = string
}

variable "service_name" {
  description = "ECS Service name"
  type        = string
}


variable "ecr_repository_url" {
  description = "The URL of the ECR repository to pull the Docker image"
  type        = string
}
