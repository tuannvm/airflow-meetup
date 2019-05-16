data "template_file" "unseal" {
  template = "${file("${path.module}/templates/unseal.tpl")}"

  vars {
    project    = "${local.project}"
    region     = "${local.region}"
    key_ring   = "${google_kms_key_ring.my_key_ring.name}"
    crypto_key = "${google_kms_crypto_key.my_crypto_key.name}"
  }
}

resource "local_file" "unseal" {
  content  = "${data.template_file.unseal.rendered}"
  filename = "${path.module}/charts/values/unseal.yaml"
}

data "template_file" "tls" {
  template = "${file("${path.module}/templates/tls.tpl")}"

  vars {
    # certificate = "${base64encode(acme_certificate.certificate.certificate_pem)}"  # private_key = "${base64encode(acme_certificate.certificate.private_key_pem)}"

    private_key = "${base64encode(file("tls/private_key"))}"
    certificate = "${base64encode(file("tls/certificate"))}"
  }
}

resource "local_file" "tls" {
  content  = "${data.template_file.tls.rendered}"
  filename = "${path.module}/charts/values/tls.yaml"
}

data "template_file" "storage" {
  template = "${file("${path.module}/templates/storage.tpl")}"

  vars {
    bucket     = "${local.name}"
    ha_enabled = "true"
  }
}

resource "local_file" "storage" {
  content  = "${data.template_file.storage.rendered}"
  filename = "${path.module}/charts/values/storage.yaml"
}
