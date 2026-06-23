resource "aws_s3_bucket" "poc" {
  bucket = "project6-poc-${random_string.suffix.result}"
}
