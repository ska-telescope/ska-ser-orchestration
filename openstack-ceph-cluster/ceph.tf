locals {
  ceph_node_applications = ["ceph"]
}

module "ceph_master" {
  source   = "../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name                     = join("-", [var.ceph.name, var.ceph.master.name])
    size                     = var.ceph.master.size
    flavor                   = var.ceph.master.flavor
    image                    = var.ceph.master.image
    availability_zone        = var.ceph.master.availability_zone
    network                  = var.ceph.master.network
    keypair                  = var.ceph.master.keypair
    jump_host                = var.ceph.master.jump_host
    external_security_groups = var.ceph.master.external_security_groups
    volumes = var.ceph.master.create_volumes ? [
      {
        name        = "data"
        size        = var.ceph.master.data_volume_size
        mount_point = ""
      },
      {
        name        = "wal"
        size        = var.ceph.master.wal_volume_size
        mount_point = ""
      },
    ] : []
    #applications = local.ceph_node_applications
  }
}

module "ceph_worker" {
  source   = "../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name                     = join("-", [var.ceph.name, var.ceph.worker.name])
    size                     = var.ceph.worker.size
    flavor                   = var.ceph.worker.flavor
    image                    = var.ceph.worker.image
    availability_zone        = var.ceph.worker.availability_zone
    network                  = var.ceph.worker.network
    keypair                  = var.ceph.worker.keypair
    jump_host                = var.ceph.worker.jump_host
    external_security_groups = var.ceph.worker.external_security_groups
    volumes = var.ceph.worker.create_volumes ? [
      {
        name        = "data"
        size        = var.ceph.worker.data_volume_size
        mount_point = ""
      },
      {
        name        = "wal"
        size        = var.ceph.worker.wal_volume_size
        mount_point = ""
      },
    ] : []
    #applications = local.ceph_node_applications
  }
}
