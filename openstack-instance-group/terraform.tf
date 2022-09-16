terraform {
  experiments = [module_variable_optional_attrs]
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}