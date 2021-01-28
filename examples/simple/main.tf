module "wireguard" {
  source = "../.."
  # cert_path = format("%s/.terraform/build", path.module)
  nodes = [
    {
      name      = "main"
      id        = 1
      public_ip = "127.0.0.1"
      prikey    = "mEd1ZIT+ODSele+LPqAsqFQt+p+NfMl53TrlXEDksVY="
      pubkey    = "zqC7rtlrpLMD2ySkt2AU2ehUuUl9kuUj+Ru5q0L3yBc="
    },
    {
      name   = "node1"
      id     = 2
      prikey = "WJPWyCmKl1H1nRn58IanbLcE9tgsR+OfhTFaNLZnqWg="
      pubkey = "uII28w1ccTtkaBMvnG4AkbGiW9NFXbi04laLavXm6mA="
      connect_subnets = {
        main = []
      }
    }
  ]
}


output "name" {
  value = module.wireguard.name
}
