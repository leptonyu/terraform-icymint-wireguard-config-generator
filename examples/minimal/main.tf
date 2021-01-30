module "wireguard" {
  source                  = "leptonyu/wireguard-config-generator/icymint"
  version                 = "0.1.0"
  allow_auto_generate_key = true # Need local install wireguard, jq and bash
  nodes = {
    main = {
      id        = 1
      public_ip = "1.2.3.4"
      connect_subnets = {
        node1 = {}
        node2 = {}
      }
    }
    node1 = {
      id = 2
      os = "macos"
    }
    node2 = {
      id = 3
    }
  }
}

resource "local_file" "wg" {
  for_each             = module.wireguard.configurations
  content              = each.value
  file_permission      = "0644"
  directory_permission = "0755"
  filename             = format("%s/.terraform/%s.conf", path.module, each.key)
}
