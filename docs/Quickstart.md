# Kargo Quick Start
## Host K8s & OS Support:
  - Fedora Server 34+ with kubeadm [(guide)](https://github.com/ContainerCraft/Kargo/blob/master/docs/Fedora.md)
  - Ubuntu Server 21.04+ with [microk8s] snap (instructions below)
    
## Hardware:
  - Minimum 16GB RAM
  - Minimum 512GB SSD
  - Minimum Intel dual core CPU
  - Hardware with Intel VT-d enabled
    
------------------------------------------------------------------------
## Instructions - Ubuntu [microk8s] 'Single Node Cluster':
  - Disclaimer: kubeadm is proof of concept developer use only, please use microk8s method for long lived use
  - Notice: Do not install microk8s snap during Ubuntu OS Install process    
### 00. Check if virtual extensions enabled
```sh
sudo apt install -y cpu-checker && clear; kvm-ok
```
  - example output:
```sh
ubuntu@ubuntu:~# kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
```
### 01. Add virtualization kernel arguments to /etc/default/grub
```sh
echo R1JVQl9ERUZBVUxUPTAKR1JVQl9USU1FT1VUPTAKR1JVQl9USU1FT1VUX1NUWUxFPWhpZGRlbgpHUlVCX0RJU1RSSUJVVE9SPWBsc2JfcmVsZWFzZSAtaSAtcyAyPiAvZGV2L251bGwgfHwgZWNobyBEZWJpYW5gCkdSVUJfQ01ETElORV9MSU5VWD0nY2dyb3VwX21lbW9yeT0xIGNncm91cF9lbmFibGU9Y3B1c2V0IGNncm91cF9lbmFibGU9bWVtb3J5IHN5c3RlbWQudW5pZmllZF9jZ3JvdXBfaGllcmFyY2h5PTAgaW50ZWxfaW9tbXU9b24gaW9tbXU9cHQgcmQuZHJpdmVyLnByZT12ZmlvLXBjaSBwY2k9cmVhbGxvYycK | base64 -d | sudo tee /etc/default/grub
```
### 02. Re-build grub bootloader
```sh
sudo update-grub
```
### 03. Install [microk8s] snap package
```sh
sudo snap install microk8s --classic --channel=1.21/edge
```
### 04. Enable [microk8s] [DNS plugin](https://microk8s.io/docs/addon-dns) (coredns)
```sh
sudo microk8s.enable dns
```
### 05. Reboot host
```sh
sudo microk8s status --wait-ready && sudo reboot
```
------------------------------------------------------------------------
## Instructions - Deploy Kargo
### 06. Label Node(s)
```
sudo microk8s kubectl label nodes --all --overwrite node-role.kubernetes.io/worker=''
sudo microk8s kubectl label nodes --all --overwrite node-role.kubernetes.io/kubevirt=''
sudo microk8s kubectl get nodes -owide
```
### 07. Create Namespace
```sh
sudo microk8s kubectl create namespace kargo
```
### 08. Apply Kargo KubeVirt and Auxiliary service manifests
  - Note; applying manifest three times to compensate for CRD startup time
```
sudo microk8s kubectl kustomize https://github.com/ContainerCraft/Kargo.git | sudo microk8s kubectl apply -f -
sudo microk8s status --wait-ready && sleep 30
sudo microk8s kubectl kustomize https://github.com/ContainerCraft/Kargo.git | sudo microk8s kubectl apply -f -
sudo microk8s status --wait-ready && sleep 30
sudo microk8s kubectl kustomize https://github.com/ContainerCraft/Kargo.git | sudo microk8s kubectl apply -f -
```
---------------------------------------------------------------------------
## OPTIONAL:
### Create a test VM
  - usrname:passwd: `ubuntu:ubuntu`
```sh
sudo microk8s status --wait-ready && sleep 60 && \
sudo microk8s kubectl apply -f https://raw.githubusercontent.com/ContainerCraft/Kargo/master/test/test.yaml && sleep 5 && \
sudo microk8s kubectl get vmi -n kargo
```
### Install kubectl and set kubeconfig
```sh
sudo snap install kubectl --classic --channel=1.21/edge
mkdir -p ~/.kube && touch ~/.kube/config && sudo microk8s config view >> ~/.kube/config
sudo usermod -aG microk8s `whoami` ; chown -fR `whoami` ~/.kube && bash
kubectl --context microk8s get all -A
```
### Install virtctl
```sh
export VIRTCTL_RELEASE=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')
sudo curl --output /usr/local/bin/virtctl -L https://github.com/kubevirt/kubevirt/releases/download/v${VIRTCTL_RELEASE}/virtctl-v${VIRTCTL_RELEASE}-linux-amd64
sudo chmod +x /usr/local/bin/virtctl
virtctl console -n kargo test
```

### Have fun experimenting with your new hypervisor!
  - [Example VM Definitions]

[microk8s]:https://microk8s.io
[Example VM Definitions]:https://github.com/ContainerCraft/qubo/tree/main/wip
