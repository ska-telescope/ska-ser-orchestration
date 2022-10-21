locals {
  ceph = defaults(var.ceph, {
    name = "ceph"
    master = {
      name             = "master"
      size             = 0
      data_volume_size = 20
      wal_volume_size  = 20
    }
    worker = {
      name             = "worker"
      size             = 0
      data_volume_size = 250
      wal_volume_size  = 20
    }

  })
}