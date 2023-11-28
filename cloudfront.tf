resource "aws_cloudfront_distribution" "hello_world_distribution" {
  origin {
    domain_name = aws_s3_bucket.hello_world_bucket.bucket_regional_domain_name
    origin_id = aws_s3_bucket.hello_world_bucket.id
  }
  enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.hello_world_bucket.id

    viewer_protocol_policy = "allow-all"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "Hello-World-distribution"
  }
}

locals {
  cloudfront_url = "https://${aws_cloudfront_distribution.hello_world_distribution.domain_name}"
}

output "cloudfront_url" {
  value = local.cloudfront_url
}
