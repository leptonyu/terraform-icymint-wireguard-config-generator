[Interface]
Address = ${node.ip}/24
%{~ if public_servers[name].port != null}
ListenPort = ${public_servers[name].port}
%{~ endif }
PrivateKey = ${node.key.pri}
%{~ for dns in node.dns }
DNS = ${dns}
%{~ endfor}
%{~ if node.mtu != null}
MTU = ${node.mtu}
%{~ endif }
%{~ if node.post != null}
%{~ for script in node.post.up }
PostUp = ${script}
%{~ endfor}
%{~ for script in node.post.down }
PostDown = ${script}
%{~ endfor}
%{~ else}
%{~ if node.os == "linux" }
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -s ${node.block_out} -o ${node.interface_out} -j MASQUERADE${node.linux_up}
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -s ${node.block_out} -o ${node.interface_out} -j MASQUERADE${node.linux_down}
%{~ endif }
%{~ endif }
%{~ if node.routes_old != null}
Table = off
%{~ for block in node.routes }
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
