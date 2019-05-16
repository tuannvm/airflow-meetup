resource "random_id" "uuid" {
  byte_length = 8
}

resource "google_storage_bucket" "image-store" {
  provider      = "google-beta"
  name          = "${local.name}"
  location      = "${local.region}"
  force_destroy = true

  encryption = {
    default_kms_key_name = "${google_kms_crypto_key.my_crypto_key.self_link}"
  }
}

data "google_service_account" "vault_kms_service_account" {
  provider   = "google-beta"
  account_id = "${local.project}-hcmc"
}

# resource "google_service_account" "vault_kms_service_account" {
#   provider     = "google-beta"
#   account_id   = "${local.name}"
#   display_name = "Vault KMS for auto-unseal"
# }

# Grant service account access to the storage bucket
resource "google_storage_bucket_iam_member" "vault-server" {
  provider = "google-beta"
  count    = "${length(local.storage_bucket_roles)}"
  bucket   = "${google_storage_bucket.image-store.name}"
  role     = "${element(local.storage_bucket_roles, count.index)}"
  member   = "serviceAccount:${data.google_service_account.vault_kms_service_account.email}"
}

resource "google_kms_key_ring" "my_key_ring" {
  provider = "google-beta"
  name     = "${local.name}-${random_id.uuid.hex}"
  location = "${local.region}"
}

resource "google_kms_crypto_key" "my_crypto_key" {
  provider        = "google-beta"
  name            = "${local.name}-${random_id.uuid.hex}"
  key_ring        = "${google_kms_key_ring.my_key_ring.self_link}"
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_key_ring_iam_binding" "key_ring" {
  provider    = "google-beta"
  key_ring_id = "${google_kms_key_ring.my_key_ring.self_link}"
  role        = "roles/owner"

  members = [
    "serviceAccount:${data.google_service_account.vault_kms_service_account.email}",

    # google default cloud storage account
    # Use https://cloud.google.com/storage/docs/getting-service-account
    "serviceAccount:service-1044889675821@gs-project-accounts.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_member" "key_ring" {
  provider = "google-beta"
  role     = "roles/iam.serviceAccountKeyAdmin"

  member = "serviceAccount:${data.google_service_account.vault_kms_service_account.email}"
}

resource "google_project_iam_member" "browser" {
  provider = "google-beta"
  role     = "roles/browser"

  member = "serviceAccount:${data.google_service_account.vault_kms_service_account.email}"
}
