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
variable "aws_api_gw_route_parent_id" {
  description = "Id of parent resource to attach path to. Example aws_api_gateway_rest_api.my_api.root_resource_id"
  type        = string
}
variable "aws_api_gw_resource_path_part" {
  description = "Path part without /. Example my_api"
  type        = string
}
variable "aws_api_gw_http_method" {
  description = "HTTP method. Example GET,PUT,POST,DELETE"
  type        = string
  default     = "GET"
}
variable "aws_lambda_invoke_arn" {
  description = "Invoke ARN for lambda."
  type        = string
}

variable "authorizer_id" {
  description = "Id of api gw authorizer."
  type        = string
  default     = null
}

variable "route_authorization_type" {
  description = "Authorization type NONE or CUSTOM"
  type        = string
  default     = "NONE"
}

variable "lambda_authorizer_id" {
  description = "Id of custom authorizer."
  type        = string
  default     = null
}

variable "api_key_required" {
  description = "API key required"
  type        = bool
  default     = false
}
