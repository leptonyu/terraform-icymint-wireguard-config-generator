locals {
  public_servers = {
    for node in var.nodes : node.name => {
      ip   = node.public_ip
      port = can(node.port) ? node.port : 51820
    } if can(node.public_ip)
  }

  servers = { for node in var.nodes : node.name => {
    ip  = cidrhost(var.cidr_block, node.id)
    pri = node.prikey
    pub = node.pubkey
    dns = coalesce(node.dns, [])
    sub = coalesce(node.subnets, [])
    con = coalesce(node.connect_subnets, {})
  } }

  links = { for name, server in local.servers : name =>
    toset(flatten([[for k, s in local.servers : k if can(s.con[name])], keys(server.con)]))
  }

  configurations = { for name, node in local.servers
    : name => templatefile(format("%s/templates/wg0.conf.tpl", path.module), {
      name           = name
      public_servers = local.public_servers
      node           = node
      link = [for l in local.links[name] : {
        name    = l
        pubkey  = local.servers[l].pub
        subnets = can(node.con[l]) ? node.con[l] : local.servers[l].sub
      }]
    })
  }
}




