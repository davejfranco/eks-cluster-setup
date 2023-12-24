terraform {
  required_version = "~> 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "5.31.0" }
    #helm       = { source = "hashicorp/helm", version = ">= 2.10" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.24.0" }
    local      = { source = "hashicorp/local", version = "~> 2.4" }
    null       = { source = "hashicorp/null", version = "~> 3.2" }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "kubernetes" {}
provider "local" {}
provider "null" {}


