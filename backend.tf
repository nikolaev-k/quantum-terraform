terraform {
 backend "gcs" {
   bucket  = "quantum-terraform-admin"
   prefix  = "terraform/state"
 }
}
