include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "git::https://git@github.com/cloudon-one/k8s-platform-modules.git//k8s-platform-istio?ref=dev"
}

locals {
  common_vars   = yamldecode(file(find_in_parent_folders("vars.yaml")))
  tool          = basename(get_terragrunt_dir())
  platform      = basename(dirname(get_terragrunt_dir()))
  resource_vars = local.common_vars["Platform-tools"]["${local.account}"]["Resources"]["${local.resource}"]
}

inputs = merge(
  local.resource_vars["inputs"],{})