locals {

  vpc = {
    name            = "demo-vpc"
    cidr            = "10.0.0.0/16"
    azs             = data.aws_availability_zones.current.names
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  }

  cluster = {
    name    = "thor"
    version = "1.27"
  }

  default_tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

