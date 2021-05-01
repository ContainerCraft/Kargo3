#!/bin/bash -ex
CALICO_RELEASE="$(\
        curl -s 'https://github.com/projectcalico/cni-plugin/releases/latest' \
        | awk -F'[v\&\"]' '/releases/{print $3}' 2>/dev/null \
)"

CALICO_URL="https://github.com/projectcalico/cni-plugin/releases/download/${CALICO_RELEASE}/calico-amd64"
CALICO_IPAM_URL="https://github.com/projectcalico/cni-plugin/releases/download/${CALICO_RELEASE}/calico-ipam-amd64"

curl -L "${CALICO_URL}" --output /opt/cni/bin/calico
curl -L "${CALICO_IPAM_URL}" --output /opt/cni/bin/calico-ipam
chmod 755 /opt/cni/bin/{calico,calico-ipam}
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
