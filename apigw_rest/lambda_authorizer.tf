module "authorizer_lambda" {
  count              = var.create_authorizer ? 1 : 0
  app_name             = var.app_name
  stack_env                = var.stack_env
  source             = "../lambda/"
  app_name    = var.app_name
  stack_env       = var.stack_env
  name               = "auth0_authorizer"
  output_path        = "${var.lambda_src_base}/authorizer/authorizer.zip"
  aws_region_primary = var.aws_region_primary
  localstack         = var.localstack
  architectures      = var.lambda_architectures
  security_group_ids = var.lambda_security_group_ids
  subnet_ids         = var.lambda_subnet_ids
  environment        = {
  }
}
