terraform {
  required_version = "~> 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.25.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "oci" {
  region = var.region
}
