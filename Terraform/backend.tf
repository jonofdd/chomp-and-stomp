terraform {
  backend "s3" {
    bucket         = "ihurezanu-alabs"
    key            = "terraform_states/harper.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}