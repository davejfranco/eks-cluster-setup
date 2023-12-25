/*
  Network 
*/
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc.name
  cidr = local.vpc.cidr

  azs             = local.vpc.azs
  private_subnets = local.vpc.private_subnets
  public_subnets  = local.vpc.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false

  tags = local.default_tags

}

/*
  EKS Cluster
*/

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.cluster.name
  cluster_version = local.cluster.version

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"

    }
    vpc-cni = {
      most_recent       = true
      resolve_conflicts = "OVERWRITE"
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # aws-auth configmap
  manage_aws_auth_configmap = false

  eks_managed_node_groups = {
    internal = {
      name            = "internal"
      use_name_prefix = true
      instance_types  = ["t3.medium"]
      min_size        = 1
      max_size        = 1
      desired_size    = 1

      update_config = {
        max_unavailable_percentage = 50
      }

      #This node group should go to the public subnets
      subnet_ids = module.vpc.private_subnets

      labels = {
        node-type = "internal"
        kind      = "ondemand"
      }

      pre_bootstrap_user_data = <<-EOT
      #!/bin/bash
      set -ex
      cat <<-EOF > /etc/profile.d/bootstrap.sh
      export CONTAINER_RUNTIME="containerd"
      #export USE_MAX_PODS=false
      #export KUBELET_EXTRA_ARGS="--max-pods=110"
      EOF
      # Source extra environment variables in bootstrap script
      sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh
      EOT
    }
  }

  tags = local.default_tags
}
