variable "localstack" {
  description = "set to true when running under local stack"
  type        = bool
  default     = false
}

variable "app_name" {
  description = "Application name prefix"
  type = string
}

variable "stack_env" {
  description = "suffix to make stack name unique"
  type        = string
}

variable "aws_account_num" {
  description = "AWS account number"
  type        = string
  default     = "000000000000"
}

variable "lambda_architectures" {
  description = "Lambda architecture. arm64 or x86_64"
  type        = string
  default     = "arm64"
}

variable "lambda_src_base" {
  description = "Base folder for lambda source code."
  type        = string
  default     = "../src"
}

variable "aws_region_primary" {
  description = "AWS primary region"
  type        = string
  default     = "us-east-1"
}

variable "aws_region_secondary" {
  description = "AWS secondary region"
  type        = string
  default     = "us-west-2"
}

variable "name" {
  description = "Name of API"
  type        = string
}

variable "stage_name" {
  description = "Name of API stage"
  type        = string
}

variable "route_hash" {
  description = "Hash of all relevant deps for deployment to trigger redeploy"
}

variable "metrics_enabled" {
  description = "Enable cloudwatch metrics for api"
  type        = bool
  default     = false
}

variable "logging_level" {
  description = "Logging Level for api-gw"
  type        = string
  default     = "ERROR"
}

variable "vpc_endpoints" {
  description = "List of vpc endpoints if creating a private api"
  type        = list(string)
  default     = null
}

variable "data_trace_enabled" {
  description = "Enable data trace in api logging"
  type        = bool
  default     = false
}

variable "create_authorizer" {
  description = "Create auth0 authorizer"
  type        = bool
  default     = false
}

variable "authorizer_ttl_in_seconds" {
  description = "Time in seconds to cache authorizer results"
  type        = number
  default     = 300
}

variable "endpoint_type" {
  description = "Endpoint type for api. EDGE, REGIONAL, PRIVATE"
  type        = string
  default     = "EDGE"
}

variable "lambda_security_group_ids" {
  description = "vpc config security_group_ids"
  type        = list(string)
  default     = []
}

variable "lambda_subnet_ids" {
  description = "vpc config subnet_ids"
  type        = list(string)
  default     = []
}
