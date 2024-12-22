provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnet" "existing" {
  id = var.subnet_id
}