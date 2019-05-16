module "gke" {
  # remote source
  source = "git::ssh://git@github.com/tuannvm/tools.git?ref=master//terraform/modules/gke"

  project                    = "${local.project}"
  region                     = "${local.region}"
  name                       = "${local.name}-hcmc"
  cluster_min_master_version = "1.11.8"
}
