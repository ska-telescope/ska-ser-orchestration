locals {
  ruleset = {
    default               = local.default_rules
    elasticsearch         = local.elasticsearch_rules
    kibana                = local.kibana_rules
    node_exporter         = local.node_exporter_rules
    docker_exporter       = local.docker_exporter_rules
    prometheus            = local.prometheus_rules
    grafana               = local.grafana_rules
    thanos_sidecar        = local.thanos_sidecar_rules
    thanos                = local.thanos_rules
    haproxy               = local.haproxy_rules
    haproxy_elasticsearch = local.haproxy_elasticsearch_rules
    ceph                  = local.ceph_rules
    nexus                 = local.nexus_rules
    reverseproxy          = local.reverseproxy_rules
    openvpn               = local.openvpn_rules
    dns                   = local.dns_rules
  }

  application_ruleset = flatten([
    for application in var.applications : [
      for rule_id, rule in local.ruleset[application] : merge(rule, { id = rule_id })
    ]
  ])

  remote_ipv4_cidrs = merge(distinct(flatten([
    [ # "public" target
      for rule in local.application_ruleset : {
        (rule.id) : ["0.0.0.0/0"]
      } if lookup(rule, "target", "network") == "public"
    ],
    [ # "network" target
      for rule in local.application_ruleset : {
        for subnet_name, subnet_cidr in local.subnets :
        (rule.id) => subnet_cidr...
      } if lookup(rule, "target", "network") == "network"
    ]
  ]))...)

  ipv4_ruleset = merge(distinct(flatten([
    [ # Port-less rules
      for rule in local.application_ruleset : {
        for cidr in lookup(local.remote_ipv4_cidrs, rule.id) :
        "${rule.id}_${substr(md5(cidr), 0, 5)}" => {
          direction        = rule.direction
          ethertype        = "IPv4"
          protocol         = rule.protocol
          port_range_min   = null
          port_range_max   = null
          remote_ip_prefix = cidr
          description      = "${rule.service} ${rule.direction} for port ${rule.protocol} by cidr ${cidr}"
          service          = rule.service
          scrape           = lookup(rule, "scrape", false)
        }
      } if length(lookup(rule, "ports", [])) == 0 && length(lookup(rule, "port_range", [])) == 0
    ],
    [ # Set of port rules
      for rule in local.application_ruleset : [
        for port in rule.ports : {
          for cidr in lookup(local.remote_ipv4_cidrs, rule.id) :
          "${rule.id}_${port}_${substr(md5(cidr), 0, 5)}" => {
            direction        = rule.direction
            ethertype        = "IPv4"
            protocol         = rule.protocol
            port_range_min   = port
            port_range_max   = port
            remote_ip_prefix = cidr
            description      = "${rule.service} ${rule.direction} for port ${port} by cidr ${cidr}"
            service          = rule.service
            scrape           = lookup(rule, "scrape", false)
          }
        }
      ] if length(lookup(rule, "ports", [])) > 0
    ],
    [ # Port range rules
      for rule in local.application_ruleset : {
        for cidr in lookup(local.remote_ipv4_cidrs, rule.id) :
        "${rule.id}_${substr(md5(cidr), 0, 5)}" => {
          direction        = rule.direction
          ethertype        = "IPv4"
          protocol         = rule.protocol
          port_range_min   = min(rule.port_range...)
          port_range_max   = max(rule.port_range...)
          remote_ip_prefix = cidr
          description      = "${rule.service} ${rule.direction} for port ${min(rule.port_range...)} through port ${max(rule.port_range...)} by cidr ${cidr}"
          service          = rule.service
          scrape           = lookup(rule, "scrape", false)
        }
      } if length(lookup(rule, "port_range", [])) == 2
    ]
  ]))...)

  # TODO: Add ipv6 support when needed
  ipv6_ruleset = {}
}