terraform {
  backend "s3" {
    bucket         = "rhy-tf-state-backend"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "tf-backend-dynamo"
  }
}