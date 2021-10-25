# Kargo Quick Start | Ubuntu
## Host K8s & OS Support:
  - Ubuntu (Server or Desktop) 21.04+ with [microk8s]
    
## Hardware:
  - Minimum 32GB RAM
  - Minimum 512GB SSD
  - Minimum Intel Quad Core CPU
  - Hardware with Intel VT-d enabled

## Hypervisor Utilization:
![utilization](./img/utilization.png)

------------------------------------------------------------------------
## Prerequisites
  - Install Dependencies
```sh
 sudo apt install git vim curl snapd cpu-checker iscsid network-manager qemu qemu-kvm libvirt0 libvirt-daemon libvirt-clients libvirt-daemon-system -y || sudo apt install git vim curl snapd cpu-checker open-iscsi network-manager qemu qemu-kvm libvirt0 libvirt-daemon libvirt-clients libvirt-daemon-system -y
```
  - Enhance KVM kernel arguments
  - The following kernel argument snippet for Intel hardware can be configured in `/etc/default/grub`
```sh
GRUB_CMDLINE_LINUX_DEFAULT="cgroup_memory=1 cgroup_enable=cpuset cgroup_enable=memory systemd.unified_cgroup_hierarchy=0 intel_iommu=on iommu=pt rd.driver.pre=vfio-pci pci=realloc"
```
  - Rebuild grub bootloader
```sh
sudo update-grub
```
  - Check if virtual extensions enabled
```sh
clear; kvm-ok &&echo&& virt-host-validate
```
  - example output:
```sh
INFO: /dev/kvm exists
KVM acceleration can be used

  QEMU: Checking for hardware virtualization                                 : PASS
  QEMU: Checking if device /dev/kvm exists                                   : PASS
  QEMU: Checking if device /dev/kvm is accessible                            : PASS
  QEMU: Checking if device /dev/vhost-net exists                             : PASS
  QEMU: Checking if device /dev/net/tun exists                               : PASS
  QEMU: Checking for device assignment IOMMU support                         : PASS
```
  - Link kvm to expected location
```sh
sudo ln -s /usr/bin/kvm /usr/libexec/qemu-kvm
```
  - Mitigate kubevirt [permissions restriction](https://github.com/kubevirt/kubevirt/issues/4303#issuecomment-830365183) on `/dev/kvm`
```sh
sudo vim /etc/apparmor.d/usr.sbin.libvirtd
```
```sh
  # append after aprox line 95
  /usr/{lib,lib64,lib/qemu,libexec}/qemu-kvm PUx,
```
```sh
sudo systemctl reload apparmor.service
```
---------------------------------------------------------------------------
## Install [Microk8s]:
### 01. Install [microk8s] snap package
```sh
sudo snap install microk8s --classic && sleep 8 && \
sudo ln -s /var/lib/kubelet/ /var/snap/microk8s/common/var/lib/kubelet/
```
### 02. Enable [microk8s] Plugins:
  - [CoreDNS plugin](https://microk8s.io/docs/addon-dns)
  - [Host Access plugin](https://microk8s.io/docs/addon-dns)
  - [Multus plugin](https://microk8s.io/docs/addon-dns)
```sh
sudo microk8s enable dns          && sudo microk8s status --wait-ready
sudo microk8s enable host-access  && sudo microk8s status --wait-ready
sudo microk8s enable multus       && sudo microk8s status --wait-ready
```
### 03. Install kubectl and write ~/kube/config
```sh
sudo snap install kubectl --classic
mkdir -p ~/.kube && touch ~/.kube/config && chmod 600 ~/.kube/config && sudo microk8s config view >> ~/.kube/config
kubectl --context microk8s get all -A
```
### 04. Enable Helm & Add Helm Repos
```sh
sudo snap install helm --classic
sudo microk8s enable helm3 && sudo microk8s status --wait-ready
helm repo add jetstack https://charts.jetstack.io
helm repo add ccio     https://containercraft.io/helm
helm repo update
```
------------------------------------------------------------------------
## Deploy Kargo
### 05. Label Node(s)
```
sudo microk8s kubectl label nodes --all --overwrite node-role.kubernetes.io/kubevirt=''
sudo microk8s kubectl label nodes --all --overwrite node-role.kubernetes.io/worker=''
sudo microk8s kubectl get nodes -owide
```
### 06. Create Namespace
```sh
sudo microk8s kubectl create namespace kargo
```
### 07. Install Cert manager
```sh
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
```
### 08. Apply Kargo KubeVirt and Auxiliary service manifests
  - Note: applying manifest twice to compensate for CRD configuration
```
kubectl kustomize https://github.com/ContainerCraft/Kargo | kubectl apply -f -
sudo microk8s status --wait-ready && sleep 10
kubectl kustomize https://github.com/ContainerCraft/Kargo | kubectl apply -f -
```
---------------------------------------------------------------------------
## OPTIONAL:

### a. Install virtctl
```sh
export VIRTCTL_RELEASE=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')
sudo curl --output /usr/local/bin/virtctl -L https://github.com/kubevirt/kubevirt/releases/download/v${VIRTCTL_RELEASE}/virtctl-v${VIRTCTL_RELEASE}-linux-amd64
sudo chmod +x /usr/local/bin/virtctl
```
### b. Create a test VM
  - Upload SSH Public Key for dynamic VM Injection
```sh
ls ~/.ssh/id_rsa.pub >/dev/null || ssh-keygen
kubectl create secret generic kargo-sshpubkey-ubuntu \
    --namespace kargo --dry-run=client -oyaml \
    --from-file=key1=$HOME/.ssh/id_rsa.pub \
  | kubectl apply -f -
```
  - Deploy Ubuntu Test VM
```sh
kubectl apply -f https://raw.githubusercontent.com/ContainerCraft/Kargo/master/test/test.yaml
```
  - Watch Kubernetes download the virtualmachine image & prepare for launch
```sh
kubectl get events -n kargo -Aw
```
  - Check for VirtualMachineInstance start
```sh
kubectl get vmi -n kargo
```
  - Connect to Virtual Machine Console
```sh
virtctl console -n kargo ubuntu
```
> Credentials: `ubuntu:ubuntu`
  - watch kargo events with this command

### c. Configure br0 interface
  - [Netplan](https://netplan.io) static IP example for Ubuntu Server
```sh
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp0s31f6:
      optional: true
      dhcp4: false
      dhcp6: false
      dhcp-identifier: mac
    enp2s0:
      optional: true
      dhcp4: false
      dhcp6: false
      dhcp-identifier: mac
  bridges:
    br0:
      dhcp4: no
      dhcp6: no
      dhcp-identifier: mac
      addresses: 
        - 192.168.1.51/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 192.168.1.1
        search:
          - home.arpa
      interfaces:
        - enp2s0
```

### d. Install OpenEBS for Storage
  - Used for configuring network bonds/bridges with kubernetes api yaml definitions
```sh
sudo microk8s enable openebs      && sudo microk8s status --wait-ready
```

### Have fun experimenting with your new hypervisor!
  - [Example VM Definitions]

[microk8s]:https://microk8s.io
[Microk8s]:https://microk8s.io
[Example VM Definitions]:https://github.com/ContainerCraft/qubo/tree/main/wip
