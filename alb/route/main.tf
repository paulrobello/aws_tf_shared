resource "aws_lb_target_group" "tg" {
  name        = "${var.app_name}-alb-tg-${var.name}-${var.stack_env}"
  target_type = "lambda"
}

resource "aws_lb_listener_rule" "listener_rule" {
  priority     = var.priority
  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
  condition {
    http_request_method {
      values = var.http_methods
    }
  }
  condition {
    path_pattern {
      values = formatlist("/${var.stage_name}%s", var.routes)
    }
  }
  condition {
    http_header {
      http_header_name = var.api_key!=null ? "x-api-key" : "accept"
      values           = [var.api_key!=null ? var.api_key : "*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = var.lambda_arn
  depends_on       = [aws_lambda_permission.allow_alb]
}

resource "aws_lambda_permission" "allow_alb" {
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.tg.arn
}
