resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_policy" "ci" {
  name = "approle"

  policy = <<EOT
# Login with AppRole
# Meant to use with gitlab
path "auth/approle/login" {
  capabilities = [ "create", "read" ]
}

path "secret/*" {
  capabilities = ["read", "list"]
}
EOT
}

resource "vault_approle_auth_backend_role" "ci" {
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "ci"
  policies  = ["${vault_policy.ci.name}"]
}

resource "vault_approle_auth_backend_role_secret_id" "ci" {
  backend   = "${vault_auth_backend.approle.path}"
  role_name = "${vault_approle_auth_backend_role.ci.role_name}"
}

resource "vault_approle_auth_backend_login" "ci" {
  backend   = "${vault_auth_backend.approle.path}"
  role_id   = "${vault_approle_auth_backend_role.ci.role_id}"
  secret_id = "${vault_approle_auth_backend_role_secret_id.ci.secret_id}"
}
