
module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = module.project-factory.project_id
  name                       = "quantum-cluster"
  region                     = "us-east4"
  zones                      = ["us-east4-a"]
  network                    = module.vpc.network_name
  network_project_id         = module.vpc.project_id
  subnetwork                 = element(module.vpc.subnets_names, 0)
  ip_range_pods              = "subnet-01-pods"
  ip_range_services          = "subnet-01-services"
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = true
  remove_default_node_pool   = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-2"
      min_count          = 1
      max_count          = 3
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "standard-node-pool"
    }
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
