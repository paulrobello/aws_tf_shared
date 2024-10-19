variable "app_name" {
  description = "Application name prefix"
  type = string
}

variable "stack_env" {
  description = "suffix to make stack name unique"
  type        = string
}

variable "aws_api_gw_rest_api_id" {
  description = "Id of rest api"
  type        = string
}

variable "aws_api_gw_root_resource_id" {
  description = "Id of root resource to attach path to. Example aws_api_gateway_rest_api.my_api.root_resource_id"
  type        = string
}
