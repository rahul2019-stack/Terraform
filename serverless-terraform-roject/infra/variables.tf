variable "lambda_role_name" {
  default = "rhy_lambda_role"
}

variable "function_name" {
  default = "rhy_dispatcher_lambda"
}

variable "runtime" {
  default = "python3.8"
}

variable "handler" {
  default = "dispatcher"
}

variable "src_path" {
  default = "../"
}

variable "lambda_read_from_sqs_fnname" {
  default = "lambda_read_from_sqs_fn"
}
variable "read_from_sqs_handler" {
  default = "read_from_sqs"
}

variable "lambda_read_from_sqs_role_name" {
  default = "lambda_read_from_sqs_role"
}