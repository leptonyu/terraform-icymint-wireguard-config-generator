[Interface]
Address = ${node.ip}/24
%{~ if public_servers[name].port !=null}
ListenPort = ${public_servers[name].port}
%{~ endif }
PrivateKey = ${node.pri}
%{~ for dns in node.dns }
DNS = ${dns}
%{~ endfor}


%{~ for lnk in link }
[Peer]
# Name = ${lnk.name}
PublicKey = ${lnk.pubkey}
%{~ endfor }