data "external" "key" {
  for_each = { for k, v in var.nodes : k => 0 if v.key == null && var.allow_auto_generate_key }
  program  = [format("%s/key_gen.sh", path.module)]
  query = {
    name = each.key
    path = var.key_path
  }
}

locals {
  defaultPersistentKeepalive = 25

  public_servers = {
    for name, node in var.nodes : name => {
      ip   = node.public_ip
      port = coalesce(node.port, 51820)
    } if can(node.public_ip)
  }

  servers = { for name, node in var.nodes : name => {
    ip     = cidrhost(var.cidr_block, node.id)
    key    = node.key != null ? node.key : coalesce(try(var.templates[node.template].key, null), data.external.key[name].result)
    dns    = node.dns != null ? node.dns : coalesce(try(var.templates[node.template].dns, var.dns), var.dns)
    sub    = node.subnets != null ? node.subnets : coalesce(try(var.templates[node.template].subnets, []), [])
    os     = node.os != null ? node.os : coalesce(try(var.templates[node.template].os, null), "linux")
    routes = flatten([[var.cidr_block], coalesce(try(var.templates[node.template].routes, null), [])])
    con = { for k, v in node.connect != null ? node.connect : coalesce(try(var.templates[node.template].connect, null), {}) : k => {
      subnets   = coalesce(v.subnets, [])
      replace   = can(v.mergeSubnetStrategy) ? v.mergeSubnetStrategy == "replace" : false
      keepalive = coalesce(v.persistentKeepalive, local.defaultPersistentKeepalive)
    } }
    mtu = node.mtu != null ? node.mtu : coalesce(try(var.templates[node.template].mtu, null), var.mtu)
    linux = {
      interface = coalesce(node.linux != null ? node.linux.interface : null, "eth0")
      block     = coalesce(node.linux != null ? node.linux.block : null, "0.0.0.0/0")
      up        = node.linux != null ? (node.linux.up != null ? node.linux.up : "") : ""
      down      = node.linux != null ? (node.linux.down != null ? node.linux.down : "") : ""
    }
    post       = node.post != null ? node.post : try(var.templates[node.template].post, null)
    routes_old = node.routes != null ? node.routes : try(var.templates[node.template].routes, null)
  } }

  links = { for name, server in local.servers : name =>
    toset(flatten([[for k, s in local.servers : k if can(s.con[name])], keys(server.con)]))
  }

  configurations = { for name, node in local.servers
    : name => templatefile(format("%s/templates/wg0.conf.tpl", path.module), {
      name           = name
      cidr           = var.cidr_block
      public_servers = local.public_servers
      node           = node
      link = { for l in local.links[name] : l => {
        pubkey = local.servers[l].key.pub
        subnets = flatten([[format("%s/32", local.servers[l].ip)], can(node.con[l])
          ? flatten([node.con[l].replace ? [] : flatten(local.servers[l].sub), node.con[l].subnets])
        : flatten(local.servers[l].sub)])
        keepalive = can(node.con[l]) ? node.con[l].keepalive : local.defaultPersistentKeepalive
      } }
    })
  }
}




