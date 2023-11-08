resource "aws_cognito_user_pool" "pool" {
  name = "mypool"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "one-percent-better"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name                                 = "client"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  callback_urls                        = ["https://example.com"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
}

variable "cognito_user_email" {}

resource "aws_cognito_user" "user" {
  user_pool_id = aws_cognito_user_pool.pool.id
  username     = "example"

  attributes = {
    email = "${var.cognito_user_email}"
    email_verified = true
  }
}
