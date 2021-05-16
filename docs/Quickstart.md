# Kargo Quick Start
## Host K8s & OS Support:
  - Fedora Server 34+ with kubeadm [example](https://github.com/ContainerCraft/Kargo/blob/master/docs/kubeadm.md)
  - Ubuntu Server 21.04+ with [microk8s] snap (instructions below)
    
## Hardware:
  - Minimum 16GB RAM
  - Minimum 512GB SSD
  - Minimum Intel dual core CPU
  - Hardware with Intel VTd enabled
    
## Instructions - Ubuntu [microk8s] 'Single Node Cluster':
### 01. Check if virtual extensions enabled
```sh
sudo apt install -y cpu-checker && clear; kvm-ok
```
  - example output:
```sh
ubuntu@ubuntu:~# kvm-ok
INFO: /dev/kvm exists
KVM acceleration can be used
```
### 02. Start [microk8s] dependency 'iscsid'
```sh
sudo systemctl enable --now iscsid
```
### 03. Install [microk8s] & kubectl Snap Packages
```sh
sudo snap install microk8s --classic --channel=1.21/edge
```
### 04. Enable [microk8s] [DNS plugin](https://microk8s.io/docs/addon-dns) (coredns)
```sh
sudo microk8s.enable dns
```
### 05. Label Node(s)
```
sudo microk8s kubectl label nodes --all --overwrite node-role.kubernetes.io/worker=''
sudo microk8s kubectl label nodes --all --overwrite node-role.kubernetes.io/kubevirt=''
sudo microk8s kubectl get nodes -owide
```
### 06. Create Namespace
```sh
sudo microk8s kubectl create namespace kargo
```
### 07. Apply Kargo KubeVirt and Auxiliary service manifests
  - Note; applying manifest twice to compensate for CRD startup time
```
sudo microk8s kubectl kustomize https://github.com/ContainerCraft/Kargo.git | sudo microk8s kubectl apply -f -
sudo microk8s status --wait-ready && sleep 15
sudo microk8s kubectl kustomize https://github.com/ContainerCraft/Kargo.git | sudo microk8s kubectl apply -f -
```
### 08. Add virtualization kernel arguments to /etc/default/grub
```sh
echo R1JVQl9ERUZBVUxUPTAKR1JVQl9USU1FT1VUPTAKR1JVQl9USU1FT1VUX1NUWUxFPWhpZGRlbgpHUlVCX0RJU1RSSUJVVE9SPWBsc2JfcmVsZWFzZSAtaSAtcyAyPiAvZGV2L251bGwgfHwgZWNobyBEZWJpYW5gCkdSVUJfQ01ETElORV9MSU5VWD0nY2dyb3VwX21lbW9yeT0xIGNncm91cF9lbmFibGU9Y3B1c2V0IGNncm91cF9lbmFibGU9bWVtb3J5IHN5c3RlbWQudW5pZmllZF9jZ3JvdXBfaGllcmFyY2h5PTAgaW50ZWxfaW9tbXU9b24gaW9tbXU9cHQgcmQuZHJpdmVyLnByZT12ZmlvLXBjaSBwY2k9cmVhbGxvYycK | base64 -d | sudo tee /etc/default/grub
```
### 09. Re-build grub bootloader
```sh
sudo update-grub
```
### 10. Reboot host
```sh
sudo microk8s status --wait-ready && sudo reboot
```
---------------------------------------------------------------------------
## OPTIONAL:
### Set Permissions
```sh
sudo usermod -aG microk8s `whoami` ; chown -fR `whoami` ~/.kube && bash
```
### Install kubectl and set kubeconfig
```sh
sudo snap install kubectl --classic --channel=1.21/edge
mkdir -p ~/.kube && touch ~/.kube/config && sudo microk8s config view >> ~/.kube/config
kubectl --context microk8s get all -A
```

### Have fun experimenting with your new hypervisor!
  - [Example VM Definitions]

[microk8s]:https://microk8s.io
[Example VM Definitions]:https://github.com/ContainerCraft/qubo/tree/main/wip
