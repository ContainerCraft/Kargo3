#!/bin/bash -ex

CNI_RELEASE="$(\
        curl -s https://github.com/containernetworking/plugins/releases/latest \
        | awk -F'[v\&\"]' '/releases/{print $3}' 2>/dev/null \
    )"

CRICTL_RELEASE="$(\
        curl -s 'https://github.com/kubernetes-sigs/cri-tools/releases/latest' \
        | awk -F'[v\&\"]' '/releases/{print $3}' 2>/dev/null \
    )"

CRICTL_URL="https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRICTL_RELEASE}/crictl-v${CRICTL_RELEASE}-linux-amd64.tar.gz"
CNI_PLUGINS_URL="https://github.com/containernetworking/plugins/releases/download/v${CNI_RELEASE}/cni-plugins-linux-amd64-v${CNI_RELEASE}.tgz"

rm -rf   /opt/cni/bin /bin/crictl
mkdir -p /opt/cni/bin
curl -L "${CRICTL_URL}"      | sudo tar -C /opt/cni/bin -xz
curl -L "${CNI_PLUGINS_URL}" | sudo tar -C /opt/cni/bin -xz
cp    -f /opt/cni/bin/crictl /bin/crictl 
chmod +x /opt/cni/bin/crictl /bin/crictl
echo "going down for a reboot"
sudo reboot
