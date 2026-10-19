terraform {
  required_version = ">= 1.9.0"

  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "~> 0.20.0"
    }
    utils = {
      source  = "netascode/utils"
      version = "= 2.1.0-beta1"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.7.0, < 3.0.0"
    }
  }
}
