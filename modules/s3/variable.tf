variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
variable "enable_destroy" {
  description = "for delete a object in the s3 bucket"
  type = bool
  default = false
}