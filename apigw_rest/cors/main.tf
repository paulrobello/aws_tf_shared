
resource "aws_api_gateway_resource" "cors_resource" {
  rest_api_id = var.aws_api_gw_rest_api_id
  parent_id   = var.aws_api_gw_root_resource_id
  path_part   = "{cors+}"
}

resource "aws_api_gateway_method" "cors_method" {
  rest_api_id   = var.aws_api_gw_rest_api_id
  resource_id   = aws_api_gateway_resource.cors_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_integration" {
  rest_api_id       = var.aws_api_gw_rest_api_id
  resource_id       = aws_api_gateway_resource.cors_resource.id
  http_method       = aws_api_gateway_method.cors_method.http_method
  type              = "MOCK"
}

resource "aws_api_gateway_method_response" "cors_response" {
  depends_on          = [aws_api_gateway_method.cors_method]
  rest_api_id         = var.aws_api_gw_rest_api_id
  resource_id         = aws_api_gateway_resource.cors_resource.id
  http_method         = aws_api_gateway_method.cors_method.http_method
  status_code         = 200
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Headers" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "cors_integration_response" {
  depends_on = [aws_api_gateway_integration.cors_integration, aws_api_gateway_method_response.cors_response]

  rest_api_id = var.aws_api_gw_rest_api_id
  resource_id = aws_api_gateway_resource.cors_resource.id
  http_method = aws_api_gateway_method.cors_method.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
  }
}

# Add CORS headers to server-side errors
resource "aws_api_gateway_gateway_response" "cors_response_4xx" {
  rest_api_id   = var.aws_api_gw_rest_api_id
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'" # replace with hostname of frontend (CloudFront)
  }
}

resource "aws_api_gateway_gateway_response" "cors_response_5xx" {
  rest_api_id   = var.aws_api_gw_rest_api_id
  response_type = "DEFAULT_5XX"

  response_templates = {
    "application/json" = "{'message':$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin" = "'*'" # replace with hostname of frontend (CloudFront)
  }
}
