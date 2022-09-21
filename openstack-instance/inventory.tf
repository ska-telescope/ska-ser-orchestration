locals {
  inventory = {
    (openstack_compute_instance_v2.instance.name) = {
      ansible_host                 = openstack_compute_instance_v2.instance.access_ip_v4
      ansible_user                 = local.user
      ansible_python_interpreter   = "python3"
      ansible_ssh_private_key_file = "${local.ssh_keys_directory}/${data.openstack_compute_keypair_v2.keypair.name}.pem"
      ansible_ssh_common_args = join(" ", [
        "-o ControlPersist=30m",
        "-o StrictHostKeyChecking=no",
        "-o ProxyCommand=\"ssh -i \"${local.ssh_keys_directory}/${data.openstack_compute_instance_v2.jump_host.key_pair}.pem\" -W %h:%p -q ${local.jump_host_user}@${data.openstack_networking_floatingip_v2.jump_host_fip.address}\"",
        "-v"
      ])
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
      services = merge([
        for rule in module.applications_ruleset.ruleset : {
          for port in range(rule.port_range_min, rule.port_range_max + 1) :
          rule.service => "${openstack_compute_instance_v2.instance.access_ip_v4}:${port}"
        }
      ]...)
      scrapes = merge([
        for rule in module.applications_ruleset.ruleset : {
          for port in range(rule.port_range_min, rule.port_range_max + 1) :
          rule.service => "${openstack_compute_instance_v2.instance.access_ip_v4}:${port}"
        } if rule.scrape == true
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