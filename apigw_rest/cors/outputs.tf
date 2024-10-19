output "method" {
  value = aws_api_gateway_method.cors_method
}

output "integration" {
  value = aws_api_gateway_integration.cors_integration
}

output "resource" {
  value = aws_api_gateway_resource.cors_resource
}