output "instance" {
  description = "Instance state"
  value = {
    id     = openstack_compute_instance_v2.instance.id
    name   = openstack_compute_instance_v2.instance.name
    flavor = openstack_compute_instance_v2.instance.flavor_name
    image = {
      name = data.openstack_images_image_v2.image.name
      id   = data.openstack_images_image_v2.image.id
    }
    volumes = [
      for volume in openstack_blockstorage_volume_v3.volume : merge(volume.metadata, {
        id     = volume.id
        device = openstack_compute_volume_attach_v2.volume_attachment[volume.metadata.key].device
      })
    ]
    network = {
      ipv4 = openstack_compute_instance_v2.instance.access_ip_v4
    }
    user            = local.user
    security_groups = local.configuration.security_groups
    ssh = {
      keypair = data.openstack_compute_keypair_v2.keypair.name
      jump_host = {
        id   = data.openstack_compute_instance_v2.jump_host.id
        user = local.jump_host_user
        ip   = data.openstack_networking_floatingip_v2.jump_host_fip.address
        interfaces = [
          data.openstack_networking_floatingip_v2.jump_host_fip.address,
          data.openstack_networking_floatingip_v2.jump_host_fip.fixed_ip
        ]
        keypair = data.openstack_compute_instance_v2.jump_host.key_pair
      }
    }
  }
}

output "inventory" {
  description = "Instance ansible inventory"
  value = {
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
    }
  }
}