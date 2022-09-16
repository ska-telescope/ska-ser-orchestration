locals {
  volumes = { for index, volume in local.configuration.volumes :
    volume.name => volume
  }
}

resource "openstack_blockstorage_volume_v3" "volume" {
  for_each          = local.volumes
  name              = "${local.configuration.name}-${each.value.name}-vol"
  description       = "${local.configuration.name}'s ${each.value.name} volume"
  size              = each.value.size
  availability_zone = local.configuration.availability_zone
  metadata = {
    key         = each.value.name
    name        = "${local.configuration.name}-${each.value.name}-vol"
    instance    = local.configuration.name
    mount_point = each.value.mount_point
    file_system = "ext4"
  }
}

resource "openstack_compute_volume_attach_v2" "volume_attachment" {
  for_each    = openstack_blockstorage_volume_v3.volume
  instance_id = openstack_compute_instance_v2.instance.id
  volume_id   = each.value.id
}