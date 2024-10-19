resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}-${var.name}-lambda_role-${var.stack_env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# IAM logging policy for the lambda function
resource "aws_iam_policy" "logging_policy" {
  name        = "${var.app_name}-${var.name}-logging_policy-${var.stack_env}"
  description = "Logging policy for ${var.name} Lambda"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          #          "logs:CreateLogGroup", # dont allow lambda to create group so we can manage it below
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the policy to the lambda role
resource "aws_iam_role_policy_attachment" "logging_policy_attachment" {
  policy_arn = aws_iam_policy.logging_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# IAM execution policy for the lambda function
resource "aws_iam_policy" "invocation_policy" {
  name = "${var.app_name}-${var.name}_lambda-invoc_plcy-${var.stack_env}"

  description = "Invocation policy for ${var.name} Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
          "autoscaling:CompleteLifecycleAction",
        ],
        Effect   = "Allow",
        Resource = aws_lambda_function.lambda.arn
      }
    ]
  })
}

# Attach the policy to the lambda role
resource "aws_iam_role_policy_attachment" "invoke_policy_attachment" {
  policy_arn = aws_iam_policy.invocation_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# IAM policy for private lambda
resource "aws_iam_policy" "vpc_policy" {
  count = length(var.subnet_ids) > 0 ? 1 : 0
  name  = "${var.app_name}-${var.name}-lambda-vpc-plcy-${var.stack_env}"

  description = "VPC policy for ${var.name} Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:CreateNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "autoscaling:CompleteLifecycleAction",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ],
        Effect = "Allow",
        #        Resource = aws_lambda_function.lambda.arn
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the lambda role
resource "aws_iam_role_policy_attachment" "vpc_policy_attachment" {
  count      = length(var.subnet_ids) > 0 ? 1 : 0
  policy_arn = aws_iam_policy.vpc_policy[0].arn
  role       = aws_iam_role.lambda_role.name
}


# ------------- [ Lambda Function ] -----------------
resource "aws_lambda_function" "lambda" {
  package_type     = var.package_type
  image_uri        = var.package_type == "Image" ? var.output_path : null
  filename         = var.package_type == "Zip" ? var.output_path : null
  source_code_hash = var.package_type == "Zip" ? filebase64sha256(var.output_path) : null
  function_name    = "${var.app_name}-${var.name}-${var.stack_env}"
  role             = aws_iam_role.lambda_role.arn
  handler          = var.package_type == "Zip" ? var.handler : null
  runtime          = var.package_type == "Zip" ? var.runtime : null
  architectures    = [var.architectures]
  memory_size      = var.memory_size
  publish          = var.publish
  timeout          = var.timeout

  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }
  environment {
    variables = merge({
      IS_LOCAL                      = var.localstack
      APP_NAME                      = var.app_name
      STACK_ENV                     = var.stack_env
      POWERTOOLS_LOG_LEVEL          = var.logging_level
      POWERTOOLS_LOGGER_SAMPLE_RATE = "1"
      LOG_MULTILINE                 = "true"
      # add common to all lambda env vars here
    }, var.environment)
  }
  # Add the Lambda Power Tools layer to list of user layers. Note Image mode does not support layers
  layers = var.package_type == "Zip" ? concat(var.layers, [local.lambda_power_tools_layer_arn]) : []
  tracing_config {
    mode = var.lambda_tracing_mode
  }
  #  depends_on = [
  #    aws_iam_role_policy_attachment.logging_policy_attachment,
  #    aws_iam_role_policy_attachment.invoke_policy_attachment,
  #    aws_iam_role_policy_attachment.vpc_policy_attachment[0]
  #  ]
}

# ------------- [ lambda logs ] -----------------

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = var.log_retention_in_days
}
