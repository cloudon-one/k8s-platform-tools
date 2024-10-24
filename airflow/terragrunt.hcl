include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "git::https://git@github.com/cloudon-one/k8s-platform-modules.git//k8s-platform-airflow?ref=dev"
}

locals {
  platform_vars = yamldecode(file(find_in_parent_folders("platform_vars.yaml")))
  tool          = basename(get_terragrunt_dir())
}

inputs = merge(
  local.platform_vars.Platform.Tools[local.tool].inputs,
  {
    environment         = local.platform_vars.common.environment
    vpc_id              = local.platform_vars.common.vpc_id
    private_subnet_ids  = local.platform_vars.common.private_subnet_ids
    eks_cluster_name    = local.platform_vars.common.eks_cluster_name
  }
)


  
