module "project-factory" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 8.0"
  name                = "quantum-test-project"
  random_project_id   = true
  org_id              = var.org_id
  billing_account     = var.billing_account
  shared_vpc          = module.vpc.project_id
  activate_apis       = ["compute.googleapis.com", "container.googleapis.com", "cloudbilling.googleapis.com"]
  group_name          = ""
}


output "gke_project_id" {
  value = module.project-factory.project_id
}
