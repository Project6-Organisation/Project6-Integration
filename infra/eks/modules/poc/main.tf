resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "poc" {
  bucket = "project6-poc-${var.environment}-${random_string.suffix.result}"
}
