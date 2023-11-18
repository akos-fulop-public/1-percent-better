resource "aws_api_gateway_rest_api" "hello_world_rest_api" {
  name = "Hello-World-REST-API"

  tags = {
    Name = "Hello-World-API-gateway"
  }
}

resource "aws_api_gateway_authorizer" "hello_world_authorizer" {
  name = "Hello-World-authorizer"
  type = "COGNITO_USER_POOLS"
  rest_api_id = aws_api_gateway_rest_api.hello_world_rest_api.id
  provider_arns = [aws_cognito_user_pool.hello_world_user_pool.arn]
}

resource "aws_api_gateway_method" "hello_world_method" {
  authorization = "COGNITO_USER_POOLS"
  http_method = "GET"
  resource_id = aws_api_gateway_rest_api.hello_world_rest_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.hello_world_rest_api.id
  authorizer_id = aws_api_gateway_authorizer.hello_world_authorizer.id
}

resource "aws_api_gateway_method_settings" "hello_world_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_rest_api.id
  stage_name  = "${aws_api_gateway_stage.hello_world_gateway_stage.stage_name}"
  method_path = "*/*"
  settings {
    logging_level = "INFO"
    data_trace_enabled = true
    metrics_enabled = true
  }
  depends_on = [ aws_api_gateway_account.hello_world_gateway_account ]
}

resource "aws_cloudwatch_log_group" "hello_world_gateway_logs" {
  name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.hello_world_rest_api.id}/${aws_api_gateway_stage.hello_world_gateway_stage.stage_name}"
  retention_in_days = 14

  tags = {
    Name = "Hello-World-API-Gateway-logs"
  }
}

resource "aws_api_gateway_integration" "hello_world_gateway_integration" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_rest_api.id
  resource_id = aws_api_gateway_rest_api.hello_world_rest_api.root_resource_id
  http_method = aws_api_gateway_method.hello_world_method.http_method
  integration_http_method = "POST"
  type = "AWS"
  uri = aws_lambda_function.hello_world_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "hello_world_method_response" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_rest_api.id
  resource_id = aws_api_gateway_rest_api.hello_world_rest_api.root_resource_id
  http_method = aws_api_gateway_method.hello_world_method.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "hello_world_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_rest_api.id
  resource_id = aws_api_gateway_rest_api.hello_world_rest_api.root_resource_id
  http_method = aws_api_gateway_method.hello_world_method.http_method
  status_code = aws_api_gateway_method_response.hello_world_method_response.status_code
  depends_on = [
    aws_api_gateway_method.hello_world_method,
    aws_api_gateway_integration.hello_world_gateway_integration
  ]
}

resource "aws_api_gateway_deployment" "hello_world_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.hello_world_rest_api.id
  depends_on = [ aws_api_gateway_integration.hello_world_gateway_integration ]
}

resource "aws_api_gateway_stage" "hello_world_gateway_stage" {
  deployment_id = aws_api_gateway_deployment.hello_world_gateway_deployment.id
  rest_api_id = aws_api_gateway_rest_api.hello_world_rest_api.id
  stage_name = "testing"

  tags = {
    Name = "Hello-World-API-gateway-stage"
  }
}

output "instance_ip_addr" {
  value = aws_api_gateway_stage.hello_world_gateway_stage.invoke_url
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world_lambda.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.hello_world_rest_api.execution_arn}/*/*/*"
}
