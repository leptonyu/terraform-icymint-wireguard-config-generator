module "wireguard" {
  source = "../.."
  nodes = {
    main = {
      id        = 1
      public_ip = "1.2.3.4"
      prikey    = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
      pubkey    = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0="
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
      prikey = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="
      pubkey = "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB0="
    }
    node2 = {
      id     = 3
      prikey = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC="
      pubkey = "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC0="
      connect_subnets = {
        main = {
          persistentKeepalive = 30
        }
      }
    }
  }
}

output "wg" {
  value = module.wireguard
}
