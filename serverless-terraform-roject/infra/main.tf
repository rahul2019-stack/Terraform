# Create s3 bucket
resource "aws_s3_bucket" "bname" {
  bucket = "rhy-for-tf-bucket"
  tags = {
    name        = "Rhy_bket"
    Environment = "dev"
  }
}

# Create iam Role for lambda
module "aws_lambda_role" {
  source           = "./modules/iamRoles/"
  lambda_role_name = "lambda_role"
}

# create iam policy for lambda to write to cloud watch and attach to above role
resource "aws_iam_role_policy" "basic_lambda_policy" {
  name = "rhy_basic_lambda_policy"
  role = module.aws_lambda_role.lambda_role_id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# In terraform ${path.module} represent pwd
provider "archive" {}
data "archive_file" "create_zip" {
  type        = "zip"
  source_file = "${var.src_path}src/dispatcher.py"
  output_path = "${var.src_path}src.zip"
}

# create lambda function
module "lambda_func" {
  source           = "./modules/lambdaFunc/"
  function_name    = var.function_name
  handler          = "${var.handler}.lambda_handler"
  lambda_role_arn  = module.aws_lambda_role.lambda_role_arn
  runtime          = var.runtime
  filename         = data.archive_file.create_zip.output_path
  source_code_hash = data.archive_file.create_zip.output_base64sha256
  sns_topic_arn    = aws_sns_topic.sns1.arn
}


# create a trigger on lambda from s3 bucket
resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
  bucket = aws_s3_bucket.bname.id
  lambda_function {
    lambda_function_arn = module.lambda_func.lambda_arn
    events              = ["s3:ObjectCreated:*"]
  }
}

#  add permission to S3 buckt to invoke lambda function
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_func.lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bname.arn
}

# create a sns and sqs resources
resource "aws_sns_topic" "sns1" {
  name = "tf_sns1"
}

resource "aws_sqs_queue" "sqs1" {
  name = "tf_sqs1"
}

# subscribe sqs to sns topic
resource "aws_sns_topic_subscription" "sns_sqs_subs" {
  topic_arn = aws_sns_topic.sns1.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs1.arn
}

# add sqs policy so that it can receive msges from sns topic
resource "aws_sqs_queue_policy" "aws_queuepolicy" {
  queue_url = aws_sqs_queue.sqs1.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "sqspolicy",
    "Statement" : [{
      "Sid" : "First",
      "Effect" : "Allow",
      "Principal" : "*",
      "Action" : "sqs:SendMessage",
      "Resource" : "${aws_sqs_queue.sqs1.arn}",
      "Condition" : {
        "ArnEquals" : {
          "aws:SourceArn" : "${aws_sns_topic.sns1.arn}"
        }
      }
      }
    ]
    }
  )
}

# code in first lambda to send json payload to sns and also add to the lambda role
resource "aws_iam_role_policy" "lambda_sns_policy" {
  name = "lambda_publish_to_sns"
  role = module.aws_lambda_role.lambda_role_id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "sns:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# configure another lambda to poll from sqs and print

# Create iam Role for second lambda
module "lambda_iam_role2" {
  source           = "./modules/iamRoles"
  lambda_role_name = var.lambda_read_from_sqs_role_name
}


# create iam policy for lambda to write to cloud watch and attach to above role
# Since event source mapping is rquired for sqs integration, add sqs:get msg and delete msg policy to lambda role
resource "aws_iam_role_policy" "lambda_policy2" {
  name = "rhy_lambda_policy_for_logs_sqs_read"
  role = module.lambda_iam_role2.lambda_role_id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:*",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

data "archive_file" "create_zip_for_lambda2" {
  type        = "zip"
  source_file = "${var.src_path}src/read_from_sqs.py"
  output_path = "${var.src_path}read_from_sqs.zip"
}

module "lambda_func2" {
  source            = "./modules/lambdaFunc"
  function_name     = var.lambda_read_from_sqs_fnname
  handler           = "${var.read_from_sqs_handler}.lambda_handler"
  lambda_role_arn   = module.lambda_iam_role2.lambda_role_arn
  runtime           = var.runtime
  filename          = data.archive_file.create_zip_for_lambda2.output_path
  source_code_hash  = data.archive_file.create_zip_for_lambda2.output_base64sha256
  aws_sqs_queue_arn = aws_sqs_queue.sqs1.arn
}

resource "aws_lambda_event_source_mapping" "lambdatriggerfromsqs" {
  event_source_arn = aws_sqs_queue.sqs1.arn
  function_name    = module.lambda_func2.lambda_arn
}

# Remove duplicated code using modules. >> Done
# Check how to debug tf file   >> Done

# Automate this process using git and jenkins