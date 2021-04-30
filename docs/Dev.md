# Kargo Developer Kubeadm K8s
This will help setup a non-prod kubevirt capable kubeadm install.

### Prereqs:
  - Fedora 34 clean install
  - Git (`dnf install git`)
  - Run all cmds as root on Kubevirt host

  1. Clone Repo
```
  git clone https://github.com/containercraft/kargo.git ~/kargo && cd ~/kargo/hack/kubeadm
```
  2. Run host prep scripts
```
  ./00-rereqs.sh
  ./01-fix-resolved.sh
  ./02-netfilter.sh
  ./03-cni-plugins.sh
```
  3. Wait for reboot
  4. Start Kubelet
```
  ./04-kubernetes.sh
```
  5. Configure with Kubeadm
```
  ./05-kubeadm-init.sh
```
  6. Add calico cni
```
  ./06-calico.sh
```
## Continue with [Kargo Quickstart]:
