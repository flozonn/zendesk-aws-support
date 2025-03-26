
resource "aws_s3_bucket" "case_ids_lookup" {
  bucket = var.id_lookup_bucket
  acl    = "private"
}

output "bucket_name" {
  value = aws_s3_bucket.case_ids_lookup.id
}