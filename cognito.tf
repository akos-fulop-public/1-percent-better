resource "aws_cognito_user_pool" "hello_world_user_pool" {
  name = "Hello-World-user-pool"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  tags = {
    Name = "Hello-World-user-pool"
  }
}

resource "aws_cognito_user_pool_domain" "hello_world_signin_domain" {
  domain = "one-percent-better"
  user_pool_id = aws_cognito_user_pool.hello_world_user_pool.id
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name = "Hello-World-userpool-client"
  user_pool_id = aws_cognito_user_pool.hello_world_user_pool.id
  callback_urls = ["https://example.com"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code", "implicit"]
  allowed_oauth_scopes = ["email", "openid"]
  supported_identity_providers = ["COGNITO"]
  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH","ALLOW_USER_PASSWORD_AUTH"]
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.userpool_client.id
}

variable "cognito_user_email" {}

resource "aws_cognito_user" "hello_world_user" {
  user_pool_id = aws_cognito_user_pool.hello_world_user_pool.id
  username = "example"

  attributes = {
    email = "${var.cognito_user_email}"
    email_verified = true
  }
}
