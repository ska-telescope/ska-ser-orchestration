output "instance" {
  description = "Instance state"
  value = {
    id     = openstack_compute_instance_v2.instance.id
    name   = openstack_compute_instance_v2.instance.name
    flavor = openstack_compute_instance_v2.instance.flavor_name
    image = {
      name = local.image.name
      id   = local.image.id
    }
    volumes = [
      for volume in openstack_blockstorage_volume_v3.volume : merge(volume.metadata, {
        id     = volume.id
        device = openstack_compute_volume_attach_v2.volume_attachment[volume.metadata.key].device
      })
    ]
    network = {
      ipv4        = openstack_compute_instance_v2.instance.access_ip_v4
      floating_ip = local.floating_ip
    }
    user            = local.user
    security_groups = local.configuration.security_groups
    keypair         = data.openstack_compute_keypair_v2.keypair.name
    jump_host       = local.jump_host
    ssh_cidr_blocks = local.ssh_cidr_blocks
  }
}

output "inventory" {
  description = "Instance ansible inventory"
  value       = local.inventory
}