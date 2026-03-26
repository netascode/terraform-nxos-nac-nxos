terraform {
  required_version = ">= 1.9.0"

  required_providers {
    utils = {
      source  = "netascode/utils"
      version = "= 2.0.0-beta1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.7.0"
    }
  }
}
