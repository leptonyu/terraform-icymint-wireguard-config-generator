output "nodes" {
  value = local.servers
}

# output "links" {
#   value = local.links
# }

output "configurations" {
  value       = local.configurations
  description = "Configuration Output"
}
