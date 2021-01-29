module "wireguard" {
  # source                  = "leptonyu/wireguard-config-generator/icymint"
  # version                 = "0.1.0"
  source                  = "../.."
  allow_auto_generate_key = true
  nodes = {
    main = {
      id        = 1
      public_ip = "1.2.3.4"
      key = {
        pri = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
        pub = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0="
      }
      connect_subnets = {
        node1 = {
          subnets             = ["8.0.0.0/8"]
          mergeSubnetStrategy = "replace"
        }
      }
    }
    node1 = {
      id     = 2
      os     = "macos"
      routes = ["10.0.0.0/16"]
      key = {
        pri = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
        pub = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB0="
      }
    }
    node2 = {
      id = 3
      # key = {
      #   pri = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC="
      #   pub = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC0="
      # }
      connect_subnets = {
        main = {
          persistentKeepalive = 30
        }
      }
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
