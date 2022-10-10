locals {
  role_applications = {
    master       = ["elasticsearch", "node_exporter"]
    data         = ["elasticsearch", "node_exporter"]
    kibana       = ["kibana", "node_exporter"]
    loadbalancer = ["haproxy", "haproxy_elasticsearch", "node_exporter"]
  }
}