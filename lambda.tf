variable "hello_world_lambda_name" {
  default = "hello_world_lambda"
}

resource "aws_iam_role" "iam_role_for_lambda_on_api_gateway" {
  name               = "iam_role_for_lambda_on_api_gateway"
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
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [ {
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }, ]
    })
  }

  inline_policy {
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [ {
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:dynamodb:*:*:table/${aws_dynamodb_table.example.name}"
      }, ]
    })
  }
}

data "archive_file" "hello_world_lambda_archive" {
  type        = "zip"
  source_file = "scripts/lambda.py"
  output_path = "tmp/hello_world_lambda_function_payload.zip"
}

resource "aws_lambda_function" "hello_world_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "tmp/hello_world_lambda_function_payload.zip"
  function_name = "${var.hello_world_lambda_name}"
  role          = aws_iam_role.iam_role_for_lambda_on_api_gateway.arn
  handler = "lambda.lambda_handler"
  runtime = "python3.10"
  source_code_hash = data.archive_file.hello_world_lambda_archive.output_base64sha256

  depends_on = [
    aws_cloudwatch_log_group.example,
  ]
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.hello_world_lambda_name}"
  retention_in_days = 14
}
