# tf-lambda-api

```terraform
module "hello_world_api" {
  source = "./modules/lambda_api"
  api_name = "hello_world_test"

  lambda_data = [
    {
      api_method = "GET"
      api_path = "/"
      lambda_function_name  = "hello"
      lambda_source_path = "./source/index.js"
      lambda_output_path = "./dest/index.zip"
      lambda_env_vars = {
        MESSAGE = "Hello"
      }
    },
    {
      api_method = "GET"
      api_path = "/goodbye"
      lambda_function_name  = "goodbye"
      lambda_source_path = "./source/index.js"
      lambda_output_path = "./dest/index.zip"
      lambda_env_vars = {
        MESSAGE = "Goodbye"
      }
    },
  ]
}
```