[Interface]
Address = ${node.ip}/24
%{~ if public_servers[name].port != null}
ListenPort = ${public_servers[name].port}
%{~ endif }
PrivateKey = ${node.key.pri}
%{~ for dns in node.dns }
DNS = ${dns}
%{~ endfor}
%{~ if node.origin.mtu != null}
MTU = ${node.origin.mtu}
%{~ endif }
%{~ if node.origin.post != null}
%{~ for script in node.origin.post.up }
PostUp = ${script}
%{~ endfor}
%{~ for script in node.origin.post.down }
PostDown = ${script}
%{~ endfor}
%{~ else}
%{~ if node.os == "linux" }
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -s ${cidr} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -s ${cidr} -j MASQUERADE
%{~ endif }
%{~ endif }
%{~ if node.origin.routes != null}
Table = off
%{~ for block in node.origin.routes }
%{~ if node.os == "macos" }
PostUp = route add ${block} -interface %i
%{~ endif }
%{~ endfor}
%{~ endif }

%{~ for ln, lnode in link }
[Peer]
# Name = ${ln}
PublicKey = ${lnode.pubkey}
PersistentKeepalive = ${lnode.keepalive}
%{~ if public_servers[ln].ip != null }
Endpoint = ${public_servers[ln].ip}:${public_servers[ln].port}
%{~ endif }
%{~ for sub in lnode.subnets }
AllowedIPs = ${sub}
%{~ endfor }
%{~ endfor }
