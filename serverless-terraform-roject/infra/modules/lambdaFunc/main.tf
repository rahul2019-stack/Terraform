resource "aws_lambda_function" "lambda_func" {
    function_name = var.function_name
    handler = var.handler
    role = var.lambda_role_arn
    runtime = var.runtime
    filename = var.filename
    source_code_hash = var.source_code_hash
    environment {
      variables = {
        sns_topic_arn = var.sns_topic_arn
        sender_sqs_topic_arn = var.aws_sqs_queue_arn
      }
    }
}

output "lambda_arn" {
  value = aws_lambda_function.lambda_func.arn
}