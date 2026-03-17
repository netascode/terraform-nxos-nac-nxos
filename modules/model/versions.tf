terraform {
  required_version = ">= 1.9.0"

  required_providers {
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
