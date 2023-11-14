resource "aws_api_gateway_account" "hello_world_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.gateway_role.arn

  depends_on = [
    aws_cloudwatch_log_group.gateway_account_logs,
    aws_cloudwatch_log_group.hello_world_gateway_logs
  ]
}

resource "aws_iam_role" "gateway_role" {
  name = "API-gateway-IAM-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [ {
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    } ]
  })

  inline_policy {
    name = "API-Gateway-Logging"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [ {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      }, ]
    })
  }
}

resource "aws_cloudwatch_log_group" "gateway_account_logs" {
  name = "/aws/apigateway/welcome"
  retention_in_days = 14
}
