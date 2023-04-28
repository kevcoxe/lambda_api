output "base_url" {
  description = "Base URL for API Gateway stage."
  value = aws_apigatewayv2_stage.lambda.invoke_url
}

output "lambda_exec_arn" {
  value = aws_iam_role.lambda_exec.arn
}

output "api_urls" {
  value = [for data in var.lambda_data : "${data.api_method} ${aws_apigatewayv2_stage.lambda.invoke_url}${data.api_path}"]
}