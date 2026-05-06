terraform {
  backend "s3" {
    bucket         = "terraformbackendhafez"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraformLock"
    encrypt        = true
  }
}
