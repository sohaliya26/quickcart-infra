resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
  force_destroy = false
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"  # Enforces IAM policies, no ACLs
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

# resource "null_resource" "empty_bucket" {
#   count = var.enable_destroy  ? 1 : 0  # Only created if destroying
  
#   provisioner "local-exec" {
#     when    = destroy
#     command = "aws s3 rm s3://quickcart-app-bucket --recursive"
#   }

#   # triggers = {
#   # bucket_name = var.bucket_name  # Use a variable instead of resource reference
#   # }
#   # triggers = {
#   #   alwasy_run = timestamp()
#   # }
# }


