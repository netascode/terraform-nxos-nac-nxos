terraform {
  required_version = ">= 1.8.0"

  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "= 0.8.0-beta7"
    }
    utils = {
      source  = "netascode/utils"
      version = "= 1.1.0-beta5"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }
}
