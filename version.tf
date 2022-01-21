terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.31.1"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.9.1"
    }
    # null = {
    #   source  = "hashicorp/null"
    #   version = "3.1.0"
    # }
  }
}
