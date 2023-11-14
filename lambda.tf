variable "hello_world_lambda_name" {
  default = "hello_world_lambda"
}

resource "aws_iam_role" "hello_world_lambda_role" {
  name = "Hello-World-lambda-IAM-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [ {
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    } ]
  })

  managed_policy_arns = [ "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" ]

  inline_policy {
    name = "Hello-World-Lambda-Logging"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [ {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }, ]
    })
  }

  inline_policy {
    name = "Hello-World-Lambda-DB-Access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [ {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Effect = "Allow"
        Resource = "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.hello_world_db_table.name}"
      }, ]
    })
  }
}

data "archive_file" "hello_world_lambda_archive" {
  type = "zip"
  source_file = "scripts/lambda.py"
  output_path = "tmp/hello_world_lambda_function_payload.zip"
}

resource "aws_lambda_function" "hello_world_lambda" {
  filename = "tmp/hello_world_lambda_function_payload.zip"
  function_name = "${var.hello_world_lambda_name}"
  role = aws_iam_role.hello_world_lambda_role.arn
  handler = "lambda.lambda_handler"
  runtime = "python3.10"
  source_code_hash = data.archive_file.hello_world_lambda_archive.output_base64sha256

  depends_on = [
    aws_cloudwatch_log_group.hello_world_lambda_logs,
  ]
}

resource "aws_cloudwatch_log_group" "hello_world_lambda_logs" {
  name = "/aws/lambda/${var.hello_world_lambda_name}"
  retention_in_days = 14
}
