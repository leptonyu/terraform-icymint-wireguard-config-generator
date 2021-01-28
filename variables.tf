terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}

variable "cidr_block" {
  default     = "192.168.78.0/24"
  type        = string
  description = "Wireguard cidr block"
}

# variable "cert_path" {
#   type        = string
#   description = "Wireguard private key path"
# }

variable "nodes" {
  type = list(object({
    name            = string
    id              = number
    prikey          = string
    pubkey          = string
    public_ip       = optional(string)
    port            = optional(number)
    subnets         = optional(list(string))
    connect_subnets = optional(map(list(string)))
    dns             = optional(list(string))
  }))

  description = "Node list"

  validation {
    condition     = length(var.nodes) == length(toset([for n in var.nodes : n.name]))
    error_message = "Name duplicated."
  }

  validation {
    condition     = length(var.nodes) == length(toset([for n in var.nodes : n.id]))
    error_message = "ID duplicated."
  }

  validation {
    condition     = alltrue([for n in var.nodes : can(regex("^[a-z]([-a-z0-9]{1,10})$", n.name))])
    error_message = "Name invalid."
  }

  validation {
    condition     = alltrue([for n in var.nodes : n.id > 0 && n.id < 255])
    error_message = "ID invalid, please value at [1, 254]."
  }

  validation {
    condition     = alltrue([for n in var.nodes : can(regex("^[a-zA-Z0-9+/]{43}=$", n.prikey))])
    error_message = "Prikey invalid."
  }

  validation {
    condition     = alltrue([for n in var.nodes : can(regex("^[a-zA-Z0-9+/]{43}=$", n.pubkey))])
    error_message = "Pubkey invalid."
  }
}
