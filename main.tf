
#s3-web-hosting-main.tf = vikas patial

resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "mybucket_ownership" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}


resource "aws_s3_bucket_public_access_block" "mybucket_public_access" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}



resource "aws_s3_bucket_acl" "mybucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.mybucket_ownership,
    aws_s3_bucket_public_access_block.mybucket_public_access,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}


resource "aws_s3_bucket_website_configuration" "mybucket_website_hosting" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }
}

module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/code"

}

resource "aws_s3_object" "mybucket_files" {
  bucket   = aws_s3_bucket.mybucket.id
  for_each = module.template_files.files

  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source_path
  content      = each.value.content

  etag = each.value.digests.md5
  acl  = "public-read"

}