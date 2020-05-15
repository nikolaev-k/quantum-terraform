config {
  module = true
  deep_check = true
  force = false

  varfile = ["gcp.auto.tfvars"]

}

rule "aws_instance_invalid_type" {
  enabled = false
}

rule "aws_instance_previous_type" {
  enabled = false
}

plugin "google" {
  enabled = true
}
