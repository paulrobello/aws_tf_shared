output "method" {
  value = aws_api_gateway_method.health_method
}

output "integration" {
  value = aws_api_gateway_integration.health_integration
}

output "resource" {
  value = aws_api_gateway_resource.health_resource
}