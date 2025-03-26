
resource "aws_s3_bucket" "case_ids_lookup" {
  bucket = "case-ids-lookup-12345"
  acl    = "private"
}

output "bucket_name" {
  value = aws_s3_bucket.case_ids_lookup.id
}