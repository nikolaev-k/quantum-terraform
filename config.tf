variable "project_name" {}
variable "billing_account" {}
variable "org_id" {}
variable "region" {}
variable "vpc_project_name" {}

provider "google" {
  region = var.region
}
