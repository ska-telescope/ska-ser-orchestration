locals {
  # Workaround to fail if jump_host (id) is not valid, as the data source does not throw an error if it does not exist
  jump_host_instance    = local.configuration.jump_host != null ? data.openstack_compute_instance_v2.jump_host[0] : null
  jump_host_id          = local.configuration.jump_host != null ? coalesce(local.jump_host_instance.id, null) : null # <--- fails when jump_host not found
  jump_host_fixed_ip    = local.jump_host_id != null ? local.jump_host_instance.access_ip_v4 : null
  jump_host_floating_ip = data.external.jump_host_floating_ip.result["fip_address"]

  jump_host_info = local.jump_host_id != null ? {
    hostname = local.jump_host_instance.name
    user     = local.jump_host_user
    ip       = local.jump_host_id != null ? coalesce(local.jump_host_floating_ip, local.jump_host_fixed_ip) : null
    keypair  = local.jump_host_instance.key_pair
  } : null
}

data "openstack_compute_instance_v2" "jump_host" {
  count = local.configuration.jump_host != null ? 1 : 0
  id    = local.configuration.jump_host
}

data "external" "jump_host_floating_ip" {
  program = [var.python, "${path.module}/scripts/get_fip_by_fixed_ip.py"]
  query = {
    ip = local.jump_host_fixed_ip
  }
}