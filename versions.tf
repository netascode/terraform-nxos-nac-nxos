terraform {
  required_version = ">= 1.9.0"

  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "~> 0.17.2"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 2.0.3, < 3.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.7.0, < 3.0.0"
    }
  }
}
