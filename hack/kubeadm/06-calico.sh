#!/bin/bash -ex
CALICO_RELEASE="$(\
        curl -s 'https://github.com/projectcalico/cni-plugin/releases/latest' \
        | awk -F'[v\&\"]' '/releases/{print $3}' 2>/dev/null \
)"

CRICTL_URL="https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRICTL_RELEASE}/crictl-v${CRICTL_RELEASE}-linux-amd64.tar.gz"
CNI_PLUGINS_URL="https://github.com/containernetworking/plugins/releases/download/v${CNI_RELEASE}/cni-plugins-linux-amd64-v${CNI_RELEASE}.tgz"
CALICO_URL="https://github.com/projectcalico/cni-plugin/releases/download/${CALICO_RELEASE}/calico-amd64"
CALICO_IPAM_URL="https://github.com/projectcalico/cni-plugin/releases/download/${CALICO_RELEASE}/calico-ipam-amd64"

curl -L "${CALICO_URL}" --output /opt/cni/bin/calico
curl -L "${CALICO_IPAM_URL}" --output /opt/cni/bin/calico-ipam
chmod 755 /opt/cni/bin/{calico,calico-ipam}
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
