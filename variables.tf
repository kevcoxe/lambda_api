# Variables
variable "api_name" {
  type = string
}

variable "lambda_data" {
  type = list(object({
    lambda_function_name = string
    lambda_source_path = string
    lambda_output_path = string
    lambda_runtime = optional(string)
    lambda_handler = optional(string)
    lambda_env_vars = optional(map(string))
    api_method = string
    api_path = string
  }))
  default = []
}