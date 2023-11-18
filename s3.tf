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

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.hello_world_bucket.bucket
  key    = aws_s3_bucket_website_configuration.hello_world_bucket_website_config.index_document[0].suffix
  source = "${path.root}/website/index.html"
  etag = filemd5("${path.root}/website/index.html")
  content_type = "text/html"
}
