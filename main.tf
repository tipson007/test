# The configuration for the `remote` backend.
terraform {
  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "Cloud-Platform"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "sam-aws-workspace"
    }
  }
}

# An example resource that does nothing.
resource "null_resource" "example" {
  triggers = {
    value = "An example resource that does nothing!!"
  }
}
