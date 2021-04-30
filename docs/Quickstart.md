# Kargo Quick Start

### Prereqs:
  - Hardware with Intel VTd (enabled)
  - Fedora Server 34 clean install
  - KubeVirt compatible K8s cluster
  - Git `dnf install git`

## On a single node 'cluster':
  0. Label Node
```
  kubectl taint nodes --overwrite --all node-role.kubernetes.io/master-
  kubectl label nodes --all --overwrite node-role.kubernetes.io/worker=''
  kubectl label nodes --all --overwrite node-role.kubernetes.io/kubevirt=''
```
  1. Create Namespace
```
  kubectl create namespace kargo
```
  2. Apply Kargo KubeVirt and Auxiliary services manifests
```
kubectl kustomize https://github.com/ContainerCraft/Kargo.git | kubectl apply -f -
```

### Have fun experimenting with your new hypervisor!
  - [Example Definitions]

-------------------------------------------------------------------------------
## References:
  - [Example kubeadm k8s development setup]

[Example kubeadm k8s development setup]:https://github.com/ContainerCraft/Kargo/blob/master/docs/Dev.md
[Example Definitions]:https://github.com/ContainerCraft/qubo/tree/main/wip