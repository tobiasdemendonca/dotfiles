function replace-lxd-token
 set TOKEN (lxc config trust add --name "charmed-maas-"(date +%s) 2>&1 | tail -1); sed -i "s|export LXD_TRUST_TOKEN=.*|export LXD_TRUST_TOKEN=\"$TOKEN\"|" ./env; fenv source ./env
end
