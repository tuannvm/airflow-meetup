//
// https://www.terraform.io/docs/providers/google/index.html
// https://www.terraform.io/docs/backends/types/gcs.html
//

provider "google-beta" {
  credentials = "${file("account.json")}"
  project     = "${local.project}"
}

provider "vault" {
  address         = "<vault-endpoint>"
  skip_tls_verify = true
  token           = "<vault-token>"
}

locals {
  project = "meetup"
  region  = "asia-southeast1"
  app     = "vault"
  role    = "hcmc"
  name    = "${local.app}-${local.project}-${local.role}"
}
