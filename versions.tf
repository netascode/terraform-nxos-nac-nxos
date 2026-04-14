terraform {
  required_version = ">= 1.9.0"

  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "= 0.9.2"
    }
    utils = {
      source  = "netascode/utils"
      version = "= 2.0.0-beta2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.7.0"
    }
  }
}
