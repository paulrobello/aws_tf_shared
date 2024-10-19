output "api" {
  value = aws_api_gateway_rest_api.api
}

output "deployment" {
  value = aws_api_gateway_deployment.deployment
}

output "stage" {
  value = aws_api_gateway_stage.stage
}

output "api_key_value" {
  description = "API Key Value"
  value       = aws_api_gateway_api_key.api_key.value
  sensitive   = true
}

output "api_key" {
  description = "API Key Id"
  value       = aws_api_gateway_api_key.api_key
}

output "auth0_authorizer" {
  value = aws_api_gateway_authorizer.auth0_authorizer
}

output "usage_plan" {
  value = aws_api_gateway_usage_plan.usage_plan
}

output "usage_plan_key" {
  value = aws_api_gateway_usage_plan_key.usage_plan_key
}

output "api_key_secret_arn" {
  value = aws_secretsmanager_secret.api_key_secret.arn
}

output "api_key_secret_name" {
  value = aws_secretsmanager_secret.api_key_secret.name
}

output "api_key_policy_arn" {
  value = aws_iam_policy.secrets_manager_read_policy.arn
}