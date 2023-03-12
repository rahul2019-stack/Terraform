# Create iam Role for lambda
resource "aws_iam_role" "lambda_iam" {
  name = var.lambda_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

output "lambda_role_id" {
  value = aws_iam_role.lambda_iam.id
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_iam.arn
}