resource "aws_api_gateway_rest_api" "rest_api" {
  name = "REST_api"
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name          = "authorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  provider_arns = [aws_cognito_user_pool.pool.arn]
}

resource "aws_api_gateway_method" "example" {
  authorization = "COGNITO_USER_POOLS"
  http_method   = "GET"
  resource_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
}

resource "aws_api_gateway_method_settings" "example_settings" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = "${aws_api_gateway_stage.example.stage_name}"
  method_path = "*/*"
  settings {
    logging_level = "INFO"
    data_trace_enabled = true
    metrics_enabled = true
  }
  depends_on = [ aws_api_gateway_account.demo ]
}

resource "aws_cloudwatch_log_group" "gateway_loggroup" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.rest_api.id}/${aws_api_gateway_stage.example.stage_name}"
  retention_in_days = 14
}

resource "aws_api_gateway_integration" "gateway_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method = aws_api_gateway_method.example.http_method
  integration_http_method = "POST"
  type        = "AWS"
  uri = aws_lambda_function.hello_world_lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method = aws_api_gateway_method.example.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method = aws_api_gateway_method.example.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  depends_on = [
    aws_api_gateway_method.example,
    aws_api_gateway_integration.gateway_integration
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  depends_on = [ aws_api_gateway_integration.gateway_integration ]
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = "testing"
}

output "instance_ip_addr" {
  value = aws_api_gateway_stage.example.invoke_url
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world_lambda.function_name
  principal = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*/*"
}
