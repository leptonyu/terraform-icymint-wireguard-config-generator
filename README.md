# Wireguard Configuration Generator


### Minimal Configuration

```HCL
module "wireguard" {
  source                  = "leptonyu/wireguard-config-generator/icymint"
  version                 = "0.1.0"
  allow_auto_generate_key = true # Need local install wireguard, jq and bash
  nodes = {
    main = {
      id        = 1
      public_ip = "1.2.3.4"
      connect = {
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

```

##### Main Node
```wireguard
[Interface]
Address = 192.168.78.1/24
ListenPort = 51820
PrivateKey = mIdNHSOam0WMtSUO8xK6/g1zEZ9l/v71NOGaGUI/SGM=
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -s 192.168.78.0/24 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -s 192.168.78.0/24 -j MASQUERADE


[Peer]
# Name = node1
PublicKey = ks5IDI0mTzmuyQPpaD3GFhMNNjHwxi67UMrl9++7uFM=
PersistentKeepalive = 25
AllowedIPs = 192.168.78.2/32
[Peer]
# Name = node2
PublicKey = Vm96L3N8gkbjc7GOdCAdu3mBW2giQ2OCrY3I3N4L80s=
PersistentKeepalive = 25
AllowedIPs = 192.168.78.3/32
```

##### Node 1

```wireguard
[Interface]
Address = 192.168.78.2/24
ListenPort = 51820
PrivateKey = kPvxt64IK3lKqxvviyKXs5gSjOejC9FNcLsl2+Xu82A=

[Peer]
# Name = main
PublicKey = y8IyGApneHP6yc6FOBczHEdBHNjhXipRIrgxBaFRnzs=
PersistentKeepalive = 25
Endpoint = 1.2.3.4:51820
AllowedIPs = 192.168.78.1/32
```