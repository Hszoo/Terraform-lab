terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

# for 예제 
# resource "aws_iam_user" "createuser" {
#   count = length(var.user_names)
#   name = var.user_names[count.index]
# }

# for-each 예제 
resource "aws_iam_user" "createuser" {
  for_each = toset(var.user_names) # list -> set 
  name = each.value
}

