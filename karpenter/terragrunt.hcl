include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "git::https://git@github.com/cloudon-one/k8s-platform-modules.git//k8s-platform-karpenter?ref=dev"
}

locals {
  platform_vars = yamldecode(file(find_in_parent_folders("platform_vars.yaml")))
  tool          = basename(get_terragrunt_dir())
}

inputs = merge(
  local.platform_vars.Platform.Tools[local.tool].inputs,
  {
    #cluster_endpoint = local.cluster_endpoint
    cluster_oidc_provider = "arn:aws:iam::${local.platform_vars.common.aws_account_id}:oidc-provider/oidc.eks.${local.platform_vars.common.aws_region}.amazonaws.com/id/${local.platform_vars.common.eks_cluster_name}"
    cluster_node_role_arn = "arn:aws:iam::${local.platform_vars.common.aws_account_id}:role/${local.platform_vars.common.eks_cluster_name}-NodeInstanceRole"
  }
)