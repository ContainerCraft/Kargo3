# Kargo Developer Kubeadm K8s
This will help setup a non-prod kubevirt capable kubeadm install.

## Prereqs:
  - Fedora Server 34 clean install
  - Git (`dnf install git`)
  - Run all cmds as root on Kubevirt host

------------------------------------------------------------------------
## Instructions - kubeadm 'single node cluster':
### 01. Clone Repo
```sh
  git clone https://github.com/containercraft/kargo.git ~/kargo && cd ~/kargo/hack/kubeadm
```
### 02. Run host prep scripts
```sh
  ./00-rereqs.sh
  ./01-fix-resolved.sh
  ./02-netfilter.sh
  ./03-cni-plugins.sh
```
### 03. Wait for reboot
### 04. Start Kubelet
```sh
  ./04-kubernetes.sh
```
### 05. Configure with Kubeadm
```sh
  ./05-kubeadm-init.sh
```
### 06. Add calico cni
```
  ./06-calico.sh
```
------------------------------------------------------------------------
## Instructions - Deploy Kargo
### 07. Label Node(s)
```
kubectl taint nodes --all --overwrite node-role.kubernetes.io/master-
kubectl label nodes --all --overwrite node-role.kubernetes.io/worker=''
kubectl label nodes --all --overwrite node-role.kubernetes.io/kubevirt=''
kubectl get nodes -owide
```
### 08. Create Namespace
```sh
kubectl create namespace kargo
```
### 09. Apply Kargo KubeVirt and Auxiliary service manifests
  - Note: applying manifest twice to compensate for CRD startup time
```
kubectl kustomize https://github.com/ContainerCraft/Kargo.git | kubectl apply -f - ; sleep 10
kubectl kustomize https://github.com/ContainerCraft/Kargo.git | kubectl apply -f -
```
---------------------------------------------------------------------------
## OPTIONAL:
### Install virtctl
```sh
export VIRTCTL_RELEASE=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')
sudo curl --output /usr/local/bin/virtctl -L https://github.com/kubevirt/kubevirt/releases/download/v${VIRTCTL_RELEASE}/virtctl-v${VIRTCTL_RELEASE}-linux-amd64
sudo chmod +x /usr/local/bin/virtctl
```
### Create a test VM
  - usrname:passwd: `ubuntu:ubuntu`
```sh
kubectl apply -f https://raw.githubusercontent.com/ContainerCraft/Kargo/master/test/test.yaml
kubectl get vmi -n kargo
virtctl console -n kargo test
```

### Have fun experimenting with your new hypervisor!
  - [Example VM Definitions]

[Example VM Definitions]:https://github.com/ContainerCraft/qubo/tree/main/wip