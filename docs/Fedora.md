# Kargo Developer Kubeadm K8s
This will help setup a non-prod kubevirt capable kubeadm install.

## Prereqs:
  - Fedora Server 34 clean install
  - Git (`dnf install git`)
  - Run all cmds as root on Kubevirt host

------------------------------------------------------------------------
## Instructions - kubeadm 'single node cluster':
### 00. Clone Repo
```sh
  git clone https://github.com/containercraft/kargo.git ~/kargo && cd ~/kargo/hack/kubeadm
```
### 01. Run host prep scripts
```sh
  ./00-rereqs.sh
  ./01-fix-resolved.sh
  ./02-netfilter.sh
  ./03-cni-plugins.sh
```
### 02. Reboot
```sh
  shutdown -r now
```
### 03. Wait for reboot & re-attain root
```sh
  sudo -i
```
### 04. Start Kubelet
```sh
  cd ~/kargo/hack/kubeadm && ./04-kubernetes.sh
```
### 05. Configure with Kubeadm
```sh
  ./05-kubeadm-init.sh
```
### 06. Add calico cni
```
  ./06-calico.sh
```
  - Wait for node to show "Ready" before continuing
```sh
watch kubectl get nodes -owide
```
------------------------------------------------------------------------
## Instructions - Deploy Kargo
### 07. Label Node(s)
```sh
kubectl taint nodes --all --overwrite node-role.kubernetes.io/master-
kubectl label nodes --all --overwrite node-role.kubernetes.io/worker=''
kubectl label nodes --all --overwrite node-role.kubernetes.io/kubevirt=''
```
### 08. Create Namespace
```sh
kubectl create namespace kargo
```
### 05. Apply Kargo KubeVirt and Auxiliary service manifests
  - Note: applying manifest four times to compensate for CRD startup time
```
kubectl kustomize https://github.com/ContainerCraft/Kargo.git | kubectl apply -f - ; sleep 30 ;\
kubectl kustomize https://github.com/ContainerCraft/Kargo.git | kubectl apply -f - ; sleep 30 ;\
kubectl kustomize https://github.com/ContainerCraft/Kargo.git | kubectl apply -f - 
```
  - Install Cert Manager if not already installed
```sh
kubectl kustomize https://github.com/ContainerCraft/Kargo/cert-manager | kubectl apply -f -
```
---------------------------------------------------------------------------
## OPTIONAL:
### Create a test VM
  - usrname:passwd: `ubuntu:ubuntu`
```sh
kubectl apply -n kargo -f https://git.io/JCVoI && sleep 60 && clear \
kubectl get vmi -n kargo
```
  - watch kargo events with this command
```sh
kubectl get events -n kargo -w
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

[Example VM Definitions]:https://github.com/ContainerCraft/qubo/tree/main/wip
