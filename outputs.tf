output "nodes" {
  value = local.servers
}

output "links" {
  value = local.servers
}

output "configurations" {
  value       = local.configurations
  description = "Configuration Output"
}
