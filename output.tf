#output.tf

output "website_endpoint" {
  value = aws_s3_bucket.mybucket.bucket_regional_domain_name
}
