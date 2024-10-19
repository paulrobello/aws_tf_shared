resource "aws_api_gateway_rest_api" "api" {
  name              = "${var.app_name}-${var.name}-${var.stack_env}"
  description       = "REST API ${var.name}"
  put_rest_api_mode = "merge"
  policy            = (var.vpc_endpoints==null || length(var.vpc_endpoints)==0) ? null : jsonencode({
    Version   = "2012-10-17",
    Statement = [
       {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "execute-api:Invoke",
        "Resource" : "arn:aws:execute-api:${var.aws_region_primary}:${var.aws_account_num}:*/${var.stage_name}/*/*",
        "Condition" : {
          "IpAddress" : {
            "aws:VpcSourceIp" : [
              "10.0.0.0/8",
              "192.168.0.0/16"
            ]
          }
        }
      }
    ]
  })

  endpoint_configuration {
    types            = [var.vpc_endpoints!=null ? "PRIVATE" : var.endpoint_type]
    vpc_endpoint_ids = var.vpc_endpoints
  }
}

# API Gateway Deployment depends on routes and methods which are referred to by route_hash
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers    = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = format("%s/%s", var.route_hash, base64sha256(aws_api_gateway_rest_api.api.policy == null ? "" : aws_api_gateway_rest_api.api.policy))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "api_log_group" {
  name              = "${var.app_name}-${var.name}_exec_logs-${var.stack_env}"
  retention_in_days = 3
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_log_group.arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

# enable full logging
resource "aws_api_gateway_method_settings" "method_settings" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"
  settings {
    logging_level      = var.logging_level
    data_trace_enabled = var.data_trace_enabled
    metrics_enabled    = var.metrics_enabled
  }
}

# custom lambda Auth0 authorizer
resource "aws_api_gateway_authorizer" "auth0_authorizer" {
  count                            = var.create_authorizer ? 1 : 0
  name                             = "${var.app_name}-${var.name}_auth0_authorizer-${var.stack_env}"
  rest_api_id                      = aws_api_gateway_rest_api.api.id
  type                             = "TOKEN"
  authorizer_uri                   = module.authorizer_lambda[0].lambda.invoke_arn
  identity_source                  = "method.request.header.Authorization"
  identity_validation_expression   = "Bearer [A-Za-z0-9]+"
  authorizer_credentials           = module.authorizer_lambda[0].lambda_role.arn
  authorizer_result_ttl_in_seconds = var.authorizer_ttl_in_seconds
}

resource "aws_api_gateway_api_key" "api_key" {
  name    = "${aws_api_gateway_rest_api.api.name}_api_key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "usage_plan" {
  name        = "${var.app_name}-${var.name}_usage_plan-${var.stack_env}"
  description = "api key usage plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.stage.stage_name
  }

  #  quota_settings {
  #    limit  = 20
  #    offset = 2
  #    period = "WEEK"
  #  }
  #
  #  throttle_settings {
  #    burst_limit = 5
  #    rate_limit  = 10
  #  }
}

resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.usage_plan.id
}
