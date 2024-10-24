terraform {
  extra_arguments "common" {
    commands = get_terraform_commands_that_need_vars()
  }
  extra_arguments "non-interactive" {
    commands = [
      "apply"

    ]
    arguments = [
      "-compact-warnings", 
    ]
  }
}

locals {
  platform_vars   = yamldecode(file(("platform_vars.yaml")))
}

remote_state {
    backend = "s3"
    generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "${local.platform_vars.common.owner}-${local.platform_vars.common.provider}-admin-${local.platform_vars.common.statebucketsuffix}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.platform_vars.common.default_region
    encrypt        = true
  }
}
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
  provider "aws" {
  region = "${local.platform_vars.common.default_region}"
}
EOF
}