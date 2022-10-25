terraform {
  experiments      = [module_variable_optional_attrs]
  required_version = "~>1.2.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~>1.48.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.1.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~>2.2.2"
    }
  }
}