#locals {
#  ceph_node_applications = ["", ""]
#}

module "ceph_master" {
  source   = "../openstack-instance-group"
  defaults = var.defaults
  providers = {
    openstack = openstack
  }

  configuration = {
    name              = join("_", [local.ceph.name, local.ceph.master.name])
    size              = local.ceph.master.size
    flavor            = local.ceph.master.flavor
    image             = local.ceph.master.image
    availability_zone = local.ceph.master.availability_zone
    network           = local.ceph.master.network
    security_groups   = []
    keypair           = local.ceph.master.keypair
    jump_host         = local.ceph.master.jump_host
    volumes = [
      {
        name        = "data"
        size        = local.ceph.master.data_volume_size
        mount_point = "/var/data"
      },
      {
        name        = "wal"
        size        = local.ceph.master.wal_volume_size
        mount_point = "/var/wal"
      },
    ]
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
    name              = join("_", [local.ceph.name, local.ceph.worker.name])
    size              = local.ceph.worker.size
    flavor            = local.ceph.worker.flavor
    image             = local.ceph.worker.image
    availability_zone = local.ceph.worker.availability_zone
    network           = local.ceph.worker.network
    security_groups   = []
    keypair           = local.ceph.worker.keypair
    jump_host         = local.ceph.worker.jump_host
    volumes = [
      {
        name        = "data"
        size        = local.ceph.worker.data_volume_size
        mount_point = "/var/data"
      },
      {
        name        = "wal"
        size        = local.ceph.worker.wal_volume_size
        mount_point = "/var/wal"
      },
    ]
    #applications = local.ceph_node_applications
  }
}