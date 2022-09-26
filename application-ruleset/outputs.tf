output "ruleset" {
  value       = merge(local.ipv4_ruleset, local.ipv6_ruleset)
  description = "Set of security group rules to support the required applications"
}