output method {
  value = aws_api_gateway_method.api_gateway_method
}

output "integration" {
  value = aws_api_gateway_integration.api_gateway_integration
}

output "resource" {
  value = aws_api_gateway_resource.api_gateway_resource
}