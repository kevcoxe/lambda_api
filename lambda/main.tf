
resource "aws_apigatewayv2_integration" "apiroute" {
  api_id = var.apigateway_api_id

  integration_uri    = aws_lambda_function.lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"

}

resource "aws_apigatewayv2_route" "apiroute" {
  api_id = var.apigateway_api_id

  route_key = "${var.api_method} ${var.api_path}"
  target    = "integrations/${aws_apigatewayv2_integration.apiroute.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.apigateway_api_execution_arn}/*/*"

}

# Lambda
data "archive_file" "node_source_print_function" {
  type        = "zip"
  source_file = "${var.lambda_source_path}"
  output_path = "${var.lambda_output_path}"
}

resource "aws_lambda_function" "lambda" {
  function_name    = var.lambda_function_name
  role             = var.lambda_role_arn
  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  filename         = "${data.archive_file.node_source_print_function.output_path}"
  source_code_hash = "${data.archive_file.node_source_print_function.output_base64sha256}"

  # Set environment variables if the "lambda_env_vars" variable is defined
  dynamic "environment" {
    for_each = var.lambda_env_vars != null ? [1] : []
    content {
      variables = var.lambda_env_vars
    }
  }
}