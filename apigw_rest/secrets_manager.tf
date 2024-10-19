resource "aws_secretsmanager_secret" "api_key_secret" {
  name_prefix = "${var.app_name}-api_key-"
}

data "aws_iam_policy_document" "secrets_manager_read_policy" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [aws_secretsmanager_secret.api_key_secret.arn]
  }
}

resource "aws_iam_policy" "secrets_manager_read_policy" {
  name        = "${var.app_name}-secrets_read_plcy-${var.stack_env}"
  description = "A policy that grants read access to a specific secret in Secrets Manager"
  policy      = data.aws_iam_policy_document.secrets_manager_read_policy.json
}

resource "aws_secretsmanager_secret_version" "api_key_secret_version" {
  secret_id     = aws_secretsmanager_secret.api_key_secret.id
  secret_string = aws_api_gateway_api_key.api_key.value
}
