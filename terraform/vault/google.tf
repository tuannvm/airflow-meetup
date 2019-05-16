//
// https://www.terraform.io/docs/providers/google/index.html
// https://www.terraform.io/docs/backends/types/gcs.html
//

provider "google-beta" {
  credentials = "${file("account.json")}"
  project     = "${local.project}"
}

locals {
  name    = "${local.project}-vault"
  project = "airflow-meetup"
  region  = "asia-southeast1"
  role    = "vault"

  storage_bucket_roles = ["roles/storage.legacyBucketReader",
    "roles/storage.objectAdmin",
  ]
}
