locals {
  inventory = {
    (openstack_compute_instance_v2.instance.name) = {
      ansible_host               = openstack_compute_instance_v2.instance.name
      ansible_user               = local.user
      ansible_python_interpreter = "python3"
      ip                         = openstack_compute_instance_v2.instance.access_ip_v4
      floating_ip                = local.floating_ip
      keypair                    = data.openstack_compute_keypair_v2.keypair.name
      jump_host                  = local.jump_host_info
      volumes = [
        for volume in openstack_blockstorage_volume_v3.volume :
        {
          id          = volume.id
          name        = volume.name
          device      = openstack_compute_volume_attach_v2.volume_attachment[volume.metadata.key].device
          mount_point = volume.metadata.mount_point
          file_system = volume.metadata.file_system
        }
      ]
      metadata = openstack_compute_instance_v2.instance.metadata
      services = merge([
        for rule in module.applications_ruleset.ruleset : {
          for port in range(rule.port_range_min, rule.port_range_max + 1) :
          rule.service => "${openstack_compute_instance_v2.instance.access_ip_v4}:${port}"
        } if rule.port_range_min != null && rule.port_range_max != null
      ]...)
      scrapes = merge([
        for rule in module.applications_ruleset.ruleset : {
          for port in range(rule.port_range_min, rule.port_range_max + 1) :
          rule.service => "${openstack_compute_instance_v2.instance.access_ip_v4}:${port}"
        } if rule.scrape == true && rule.port_range_min != null && rule.port_range_max != null
      ]...)
    }
  }
}

# Null resource to store the inventory in the state without an output
resource "null_resource" "inventory" {
  triggers = {
    type      = "instance"
    inventory = base64encode(jsonencode(local.inventory))
  }
}