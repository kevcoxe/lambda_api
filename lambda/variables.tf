variable "apigateway_api_id" {
  type = string
}

variable "apigateway_api_execution_arn" {
  type = string
}


variable "api_method" {
  type = string
  default = "GET"
}

variable "api_path" {
  type = string
  default = "/"
}

variable "lambda_role_arn" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "lambda_source_path" {
  type = string
}

variable "lambda_output_path" {
  type = string
}

variable "lambda_runtime" {
  type = string
  default = "nodejs14.x"
}

variable "lambda_handler" {
  type = string
  default = "index.handler"
}

variable "lambda_env_vars" {
  type    = map(string)
  default = null
}