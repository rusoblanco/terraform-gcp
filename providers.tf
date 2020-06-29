terraform {
  required_version = "~> 0.12.6"
  required_providers {
    random     = "~>2.2"
    null       = "~>2.1"
    kubernetes = "~>1.11.3"
  }
}

provider "google" {
  version     = "<4.0,>= 3.25"
  credentials = file("account.json")
  project     = var.gcp_project
  region      = var.region
  zone        = var.zone
  batching {
    enable_batching = false
    send_after      = "15s"
  }
}
