
#######################################################################################
# Install kubectl
#export verKubectl=$(curl -L -s https://dl.k8s.io/release/stable.txt)
#curl -LO "https://dl.k8s.io/release/${verKubectl}/bin/linux/amd64/kubectl"
#curl -LO "https://dl.k8s.io/${verKubectl}/bin/linux/amd64/kubectl.sha256"
#echo "$(<kubectl.sha256) kubectl" | sha256sum --check

#######################################################################################
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
echo '1' > /proc/sys/net/ipv4/ip_forward
sudo sysctl --system


cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
cat <<EOF | sudo tee /etc/modules-load.d/libvirtd.conf
vfio-pci
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set up required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system


#######################################################################################
# install kubeadm https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
