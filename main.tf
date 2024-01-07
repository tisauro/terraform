terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-2"
}

# Variable definition
variable "app_server_port" {
  description = "App Server Port"
  type        = number
  default     = 8080
}