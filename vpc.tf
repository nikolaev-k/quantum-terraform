resource "random_id" "id" {
  byte_length = 4
  prefix = join("", [
    var.vpc_project_name,
    "-"])
}

resource "google_project" "vpc_project" {
  name = var.vpc_project_name
  project_id = random_id.id.hex
  billing_account = var.billing_account
  org_id = var.org_id
}

resource "google_project_service" "service" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com"
  ])

  service = each.key

  project = google_project.vpc_project.project_id
  disable_on_destroy = false
}


module "vpc" {
  source = "terraform-google-modules/network/google"
  version = "~> 2.3"

  project_id = google_project.vpc_project.project_id
  network_name = "quantum-shared-vpc-network"
  routing_mode = "GLOBAL"
  shared_vpc_host = true

  subnets = [
    {
      subnet_name = "subnet-01"
      subnet_ip = "10.10.10.0/24"
      subnet_region = "us-east4"
    }
  ]

  secondary_ranges = {
    "subnet-01" = [
      {
        range_name    = "subnet-01-pods"
        ip_cidr_range = "192.168.64.0/24"
      },
      {
        range_name    = "subnet-01-services"
        ip_cidr_range = "192.168.65.0/24"
      },
    ]
  }

  routes = [
    {
      name                   = "egress-internet"
      description            = "route through IGW to access internet"
      destination_range      = "0.0.0.0/0"
      tags                   = "egress-inet"
      next_hop_internet      = "true"
    }
  ]
}

output "vpc_project_id" {
  value = google_project.vpc_project.project_id
}
