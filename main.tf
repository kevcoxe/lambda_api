locals {
  gw_name = "${var.api_name}-gw"
  api_gw_stage_name = "${var.api_name}-gw-stage"
  lambda_role = "${var.api_name}-role"
  lambda_policy = "${var.api_name}-policy"
}

resource "aws_apigatewayv2_api" "lambda" {
  name          = local.gw_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = local.api_gw_stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}


# Lambda
module "lambda_apis" {
  source = "./lambda"
  for_each = { for data in var.lambda_data : data.lambda_function_name => data }

  api_method = each.value.api_method
  api_path = each.value.api_path

  lambda_function_name = each.key
  lambda_source_path = each.value.lambda_source_path
  lambda_output_path = each.value.lambda_output_path

  lambda_env_vars = each.value.lambda_env_vars

  lambda_role_arn = aws_iam_role.lambda_exec.arn


  apigateway_api_id = aws_apigatewayv2_api.lambda.id
  apigateway_api_execution_arn = aws_apigatewayv2_api.lambda.execution_arn
}

# IAM
resource "aws_iam_policy" "lambda_logs_policy" {
  name = local.lambda_policy
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_exec" {
  name = local.lambda_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_logs_policy.arn
  role       = aws_iam_role.lambda_exec.name
}
