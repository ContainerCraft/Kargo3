cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.bak
cat <<EOF | tee /etc/systemd/resolved.conf
[Resolve]
DNS=8.8.8.8
DNSStubListener=no
EOF
mkdir -p /run/systemd/resolve
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
systemctl stop dnsmasq
systemctl disable dnsmasq
pkill -KILL dnsmasq
systemctl restart systemd-resolved.service
sleep 5
cat /etc/resolv.conf
netstat -tulpn | grep ':53 '
