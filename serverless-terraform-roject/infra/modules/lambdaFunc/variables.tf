variable "function_name" {
    default = " "
}


variable "handler" {
    default = " "
}

variable "lambda_role_arn" {
  default = " "
}

variable "runtime"{
    default = ""
}

variable "filename" {
  default = ""
}

variable "source_code_hash"{
    default = ""
}

variable "sns_topic_arn" {
    default = "NA" 
}

variable "aws_sqs_queue_arn" {
  default = ""
}