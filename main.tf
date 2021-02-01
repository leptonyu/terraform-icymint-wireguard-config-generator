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
    key    = node.key != null ? node.key : try(var.templates[node.template].key, data.external.key[name].result)
    dns    = node.dns != null ? node.dns : try(var.templates[node.template].dns, var.dns)
    sub    = node.subnets != null ? node.subnets : try(var.templates[node.template].subnets, [])
    os     = node.os != null ? node.os : try(var.templates[node.template].os, "linux")
    routes = flatten([[var.cidr_block], node.routes != null ? node.routes : try(var.templates[node.template].routes, [])])
    con = { for k, v in node.connect != null ? node.connect : try(var.templates[node.template].connect, {}) : k => {
      subnets   = coalesce(v.subnets, [])
      replace   = can(v.mergeSubnetStrategy) ? v.mergeSubnetStrategy == "replace" : false
      keepalive = coalesce(v.persistentKeepalive, local.defaultPersistentKeepalive)
    } }
    mtu        = try(node.mtu, var.templates[node.template].mtu)
    post       = try(node.post, var.templates[node.template].post)
    routes_old = try(node.routes, var.templates[node.template].routes)
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
        pubkey    = local.servers[l].key.pub
        subnets   = flatten([[format("%s/32", local.servers[l].ip)], can(node.con[l]) ? [node.con[l].replace ? [] : local.servers[l].sub, node.con[l].subnets] : [local.servers[l].sub]])
        keepalive = can(node.con[l]) ? node.con[l].keepalive : local.defaultPersistentKeepalive
      } }
    })
  }
}




