resource "aws_s3_bucket" "hello_world_bucket" {
  bucket = "hello-world-static-bucket"

  tags = {
    Name        = "Hello-World-s3-bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "hello_world_bucket_website_config" {
  bucket = aws_s3_bucket.hello_world_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "hello_world_bucket_public_access" {
  bucket = aws_s3_bucket.hello_world_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "hello_world_bucket_policy" {
  bucket = aws_s3_bucket.hello_world_bucket.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.hello_world_bucket.id}/*"
        }
      ]
    }
  )
  depends_on = [ aws_s3_bucket_public_access_block.hello_world_bucket_public_access ]
}

output "bucket_public_url" {
  value = aws_s3_bucket_website_configuration.hello_world_bucket_website_config.website_endpoint
}

module "template_files" {
  source = "hashicorp/dir/template"

  base_dir = "${path.module}/website"
  template_vars = {
    gateway_url = "${aws_api_gateway_stage.hello_world_gateway_stage.invoke_url}",
    aws_region = "${var.region}",
    cognito_client_id = "${aws_cognito_user_pool_client.userpool_client.id}",
    cognito_domain = "${aws_cognito_user_pool_domain.hello_world_signin_domain.domain}"
    s3_entrypoint = "${aws_s3_bucket_website_configuration.hello_world_bucket_website_config.website_endpoint}"
    cloudfront_domain = "${local.cloudfront_url}"
  }
  template_file_suffix = ".tftpl"
}

resource "aws_s3_object" "static_files" {
  for_each = module.template_files.files

  bucket       = aws_s3_bucket.hello_world_bucket.bucket
  key          = each.key
  content_type = each.value.content_type
  source  = each.value.source_path
  content = each.value.content
  source_hash = each.value.digests.md5
  etag = each.value.digests.md5
}
