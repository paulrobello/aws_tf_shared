resource "aws_api_gateway_resource" "api_gateway_resource" {
  rest_api_id = var.aws_api_gw_rest_api_id
  parent_id   = var.aws_api_gw_route_parent_id
  path_part   = var.aws_api_gw_resource_path_part
}

resource "aws_api_gateway_method" "api_gateway_method" {
  rest_api_id      = var.aws_api_gw_rest_api_id
  resource_id      = aws_api_gateway_resource.api_gateway_resource.id
  http_method      = var.aws_api_gw_http_method
  authorization    = var.route_authorization_type
  authorizer_id    = var.lambda_authorizer_id
  api_key_required = var.api_key_required
}

resource "aws_api_gateway_integration" "api_gateway_integration" {
  rest_api_id             = var.aws_api_gw_rest_api_id
  resource_id             = aws_api_gateway_resource.api_gateway_resource.id
  http_method             = aws_api_gateway_method.api_gateway_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.aws_lambda_invoke_arn
}

resource "aws_api_gateway_method_response" "method_response" {
  rest_api_id = var.aws_api_gw_rest_api_id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.api_gateway_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  depends_on = [
    aws_api_gateway_integration.api_gateway_integration
  ]
  rest_api_id = var.aws_api_gw_rest_api_id
  resource_id = aws_api_gateway_resource.api_gateway_resource.id
  http_method = aws_api_gateway_method.api_gateway_method.http_method
  status_code = aws_api_gateway_method_response.method_response.status_code
}
