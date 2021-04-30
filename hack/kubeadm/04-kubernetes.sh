#!/bin/bash -x

pathRun="$(pwd)"
pathDir="/usr/local/bin"

K8S_RELEASE_STABLE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
#K8S_RELEASE_STABLE="v1.20.0"
K8S_RELEASE_GIT="$(\
        curl -s 'https://github.com/kubernetes/release/releases' \
	| awk -F'[v\&\"]' '/tag_name/{print $3; exit}' 2>/dev/null \
    )"

K8S_DOWNLOAD_URL="https://storage.googleapis.com/kubernetes-release/release/${K8S_RELEASE_STABLE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}"
KUBERNETES_RELEASE_URL="https://raw.githubusercontent.com/kubernetes/release/v${K8S_RELEASE_GIT}/cmd/kubepkg/templates/latest"

# Download kubeadm,kubelet,kubectl
cd ${pathDir}
curl --location --remote-name-all ${K8S_DOWNLOAD_URL}
chmod +x ${pathDir}/{kubeadm,kubelet,kubectl}
cd ${pathRun}

# Download kubelet systemd unit file and systemd unit config
mkdir -p /etc/systemd/system/kubelet.service.d
systemctl stop kubelet

curl -sSL "${KUBERNETES_RELEASE_URL}/deb/kubeadm/10-kubeadm.conf" \
    | sed "s:/usr/bin:${pathDir}:g" \
    | tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

curl -sSL "${KUBERNETES_RELEASE_URL}/deb/kubelet/lib/systemd/system/kubelet.service" \
    | sed "s:/usr/bin:${pathDir}:g" \
    | tee /etc/systemd/system/kubelet.service

sudo cp -f /etc/containerd/config.toml /etc/containerd/config.toml.bak
sudo cp -f etc/containerd/config.toml /etc/containerd/config.toml

systemctl daemon-reload
systemctl restart containerd
systemctl enable --now kubelet
#!/bin/bash -x
#######################################################################################
# Install kubectl
dir_bin="../bin"
binKubectl="${dir_bin}/kubectl"
verKubectl="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
mkdir -p ${dir_bin}
curl --output ${binKubectl} -L "https://dl.k8s.io/release/${verKubectl}/bin/linux/amd64/kubectl"
chmod +x ${binKubectl}

#curl -L "https://dl.k8s.io/${verKubectl}/bin/linux/amd64/kubectl.sha256"
#echo "$(<kubectl.sha256) kubectl" | sha256sum --check

# install -o ${USER} -g ${USER} -m 0755 ../bin/kubectl ~/.local/bin/kubectl
# source <(kubectl completion bash)

#######################################################################################
# install kubeadm https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
