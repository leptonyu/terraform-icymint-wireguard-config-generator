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

variable "dns" {
  default     = []
  type        = list(string)
  description = "Wireguard default dns"
}

variable "allow_auto_generate_key" {
  default     = false
  type        = bool
  description = "Allow auto generate wireguard keys, you have install wireguard and jq locally and can run bash shell."
}

variable "key_path" {
  default     = "wg_keys"
  type        = string
  description = "Specify auto generated keys store path."
}


variable "mtu" {
  default     = 1420
  type        = number
  description = "Wireguard"
}

variable "templates" {
  default = {}
  type = map(object({
    key = optional(object({
      pri = string
      pub = string
    }))
    os     = optional(string)
    mtu    = optional(number)
    routes = optional(list(string))
    post = optional(object({
      up   = list(string)
      down = list(string)
    }))
    port    = optional(number)
    subnets = optional(list(string))
    connect = optional(map(object({
      subnets             = optional(list(string))
      mergeSubnetStrategy = optional(string)
      persistentKeepalive = optional(number)
    })))
    dns = optional(list(string))
  }))
  description = "Connect Template "
}

variable "nodes" {
  type = map(object({
    id       = number
    template = optional(string)
    key = optional(object({
      pri = string
      pub = string
    }))
    os     = optional(string)
    mtu    = optional(number)
    routes = optional(list(string))

    linux = optional(map(object({
      interface = optional(string)
      block     = optional(string)
      up        = optional(string)
      down      = optional(string)
    })))

    post = optional(object({
      up   = list(string)
      down = list(string)
    }))
    public_ip = optional(string)
    port      = optional(number)
    subnets   = optional(list(string))
    connect = optional(map(object({
      subnets             = optional(list(string))
      mergeSubnetStrategy = optional(string)
      persistentKeepalive = optional(number)
    })))
    dns = optional(list(string))
  }))

  description = "Wireguard node list"

  validation {
    condition     = length(var.nodes) == length(toset([for k, n in var.nodes : k]))
    error_message = "Name duplicated."
  }

  validation {
    condition     = length(var.nodes) == length(toset([for k, n in var.nodes : n.id]))
    error_message = "ID duplicated."
  }

  validation {
    condition     = alltrue([for k, n in var.nodes : can(regex("^[a-z]([_a-z0-9]{1,10})$", k))])
    error_message = "Name invalid."
  }

  validation {
    condition     = alltrue([for n in var.nodes : n.id > 0 && n.id < 255])
    error_message = "ID invalid, please value at [1, 254]."
  }

  validation {
    condition     = alltrue([for n in var.nodes : coalesce(n.mtu, 1500) > 1000 && coalesce(n.mtu, 1500) < 10000])
    error_message = "MTU invalid, please value at [1, 254]."
  }

  validation {
    condition     = alltrue([for n in var.nodes : can(regex("^(linux|macos|ios|android|app)$", coalesce(n.os, "linux")))])
    error_message = "OS invalid."
  }

  validation {
    condition     = alltrue([for n in var.nodes : coalesce(n.os, "linux") == "macos" || length(coalesce(n.routes, [])) == 0])
    error_message = "Only macos not support routes."
  }

  validation {
    condition     = alltrue([for n in var.nodes : coalesce(n.port, 58120) > 0 && coalesce(n.port, 58120) < 65535])
    error_message = "Port invalid."
  }

  validation {
    condition     = alltrue([for n in var.nodes : can(regex("^[a-zA-Z0-9+/]{43}=$", n.key.pri)) if n.key != null])
    error_message = "Prikey invalid."
  }

  validation {
    condition     = length([for n in var.nodes : n if n.key != null]) == length(toset([for k, n in var.nodes : n.key.pri if n.key != null]))
    error_message = "Prikey duplicated."
  }


  validation {
    condition     = alltrue([for n in var.nodes : can(regex("^[a-zA-Z0-9+/]{43}=$", n.key.pub)) if n.key != null])
    error_message = "Pubkey invalid."
  }

  validation {
    condition     = length([for n in var.nodes : n if n.key != null]) == length(toset([for k, n in var.nodes : n.key.pub if n.key != null]))
    error_message = "Pubkey duplicated."
  }

  validation {
    condition = alltrue([for n in var.nodes :
      alltrue([for c in coalesce(n.connect, {}) : can(regex("^(replace|merge)$", coalesce(c.mergeSubnetStrategy, "merge")))])
    ])
    error_message = "MergeSubnetStrategy invalid, use replace/merge ."
  }
}
