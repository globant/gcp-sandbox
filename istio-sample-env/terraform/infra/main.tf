provider "google" {
  credentials = "${file("../../secrets/credentials.json")}"
}

terraform {
  required_version = ">= 0.10.0"

  backend "gcs" {
    bucket = "tf-remote-state-test"
    prefix = "istio-sample-env/state"
  }
}