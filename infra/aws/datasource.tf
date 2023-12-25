
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "current" {
  filter {
    name   = "region-name"
    values = [data.aws_region.current.name]
  }
}

