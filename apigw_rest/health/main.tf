
resource "aws_api_gateway_resource" "health_resource" {
  rest_api_id = var.aws_api_gw_rest_api_id
  parent_id   = var.aws_api_gw_root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health_method" {
  rest_api_id   = var.aws_api_gw_rest_api_id
  resource_id   = aws_api_gateway_resource.health_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health_integration" {
  rest_api_id       = var.aws_api_gw_rest_api_id
  resource_id       = aws_api_gateway_resource.health_resource.id
  http_method       = aws_api_gateway_method.health_method.http_method
  type              = "MOCK"
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}

resource "aws_api_gateway_method_response" "health_response" {
  depends_on          = [aws_api_gateway_method.health_method]
  rest_api_id         = var.aws_api_gw_rest_api_id
  resource_id         = aws_api_gateway_resource.health_resource.id
  http_method         = aws_api_gateway_method.health_method.http_method
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

resource "aws_api_gateway_integration_response" "health_integration_response" {
  depends_on = [aws_api_gateway_integration.health_integration, aws_api_gateway_method_response.health_response]

  rest_api_id = var.aws_api_gw_rest_api_id
  resource_id = aws_api_gateway_resource.health_resource.id
  http_method = aws_api_gateway_method.health_method.http_method
  status_code = 200
  response_templates = {
    "application/json" = jsonencode({
      "status":"YOLO"
    })
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'"
  }
}
