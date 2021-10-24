# Kargo Quick Start | Ubuntu
## Host K8s & OS Support:
  - Ubuntu Server 21.04+ with [microk8s]
    
## Hardware:
  - Minimum 32GB RAM
  - Minimum 512GB SSD
  - Minimum Intel Quad Core CPU
  - Hardware with Intel VT-d enabled

------------------------------------------------------------------------
## Prerequisites
  - Install Dependencies
```sh
sudo apt install vim git curl snapd cpu-checker iscsid network-manager qemu qemu-kvm libvirt0 libvirt-daemon libvirt-clients libvirt-daemon-system -y || sudo apt install git vim curl snapd cpu-checker open-iscsi network-manager qemu qemu-kvm libvirt0 libvirt-daemon libvirt-clients libvirt-daemon-system -y
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
sudo ln -s /etc/apparmor.d/usr.sbin.libvirtd /etc/apparmor.d/disable/
```
```sh
cat <<EOF | base64 -d | gzip -d | sudo tee /etc/apparmor.d/usr.sbin.libvirtd && sudo systemctl reload apparmor.service
H4sIAAAAAAAAA61YWY/bNhB+968Y7D7Ea0hWURQBWtSLtLkQoGmDzdGHojAocWQTpkiFpHzA8H/vkJJ8ysomKZDNrme+GQ45t2+FymTFEX51lWKpRJvMpE6ZvB882/7x5vdPbx4+7CY3UqRLYdzNYFAanQuJ0FA4JJU1iU2FSvakXLKZnQyZcyybT7mwmVYKM4f8DrYDgNv9oSy1zrDMCa1skjKL99fZPK3s/YD4GStZKqRwG1gIKaNTkkI3ZbwQqoNu2OqMatHNBD8nbmynCk8vNK8kdjBKb2kng2WZ66Ar0QnP5kbrCzy66sJMzrKpXqIxgp8r8iyDjE8tMpPNz7i5Xik0Z8RsTtTLY0v6eEYtFkqf25IT9MJAVnHhpisj3Ll9osymUmeLyPvzFv5E5Ehxow0sc6EvH8Wg1ZXx70W8QlfKgS5DWEyGZhUZK9kS7wDie0iiTggobekJ7wJku2QmiXam2gdt8hmLKhmNOS6DgqrW8EVkML/hAOXGknxhgalNbYKFSnE0kBAanAYvC4oVaCkq0HZbWmh/Fy+S1NZG3og+a/uVjEb9arZRsuvX0m9B0P5lU3rP3+sYjcKjUrautFmAoD+AigCyIjon85m5pD69gn56CaffUqgFNFWhJZNnFl3aG3pAB7f7cI3j8scSCkHgcGMfOkqsYWhR8QgMZij87d2mxEltGTDOzURphVAimslQshTlpFJUJXMylR8Ad+GkurLA0Cd0FP6+qyUPIlEf7Nm2KdpTH3m7XixXtmD2cy/mUPEfg258Hdd+tWKmmKyf5/LIDm7nYS0uHAZH6KPDzrVRgZoMb3zDuIngxqEpbjqeMTj2FTk200VBnsyCWxMCOKNlm8JxSjV3hvEcZYnm233edswkZMK01jqttd5du8Kx6X0KmsswKfUKmg4MK+HmlJ2oXhtWzkVmX72IgAuy2d+TbKd+YikEhaK4X1Hl8p+/L7Bbn/zzQ/wzi/N/R4/9K7zALRwnhrSajv5ckcFkYw6zCi0VWaop4Wa6omKBWWVCmwqd+v9IyLvmKa+cfGQgHR6Ea/VPvM4nkJJV+9lIWGjRfYF8EZOf0GxAohKoQqMJQ5ivQHvNlsYmhBX9YwShSM2FsY4wWWWBfFsrFGoW9Lk5NncYw+v6LivKDZhTIwXm3b6h+9IDCT+3tSeOSTaBMDr4tmJWxUIGAxOfoSN493EdePb0o8/hS0oAedulntEJ4oxzAG89LdrRTZPK9wibWTEV/ETZlrgR/Tz9aZesUcU+fylxvSL/0WktLY2jiz6hxsYOAK4xq/WOkmbUXcvY0ls1NaBT7blUuZmZKj2BNqiQvvFiWVwxz/8fMAe1y7m2Lq4smnhWVl8r5/vn40XIR0LntnnxED8PbS6kNFqvKDaoLE0xFaULW8SUG0ozM85+OdD+9oPgB/0Bi/IVxdKQklA3ecUotxUP2cQUYFoLgM0MCYeg87ODt6wdHULMj0CszaEbU/j7sKY3AZ1DKDqMHYp0GEeBIw1nbUiFQGNlyUyhDU3qVPsMRfU6LBXHeHTZHjfmeysoBzrANLEmCzQKZdJWo71wkiNzFWVW5zG9kgVz2Zzy9+slx6O9TD+wSXPbpHgToYfr+gDoZjW//Ru6JiXEuhcp9CnOP3GLmWu9sKHCFEdcn6J1SBzxjpvcnKmZfyAqfrQuwMePb17EfqvkYebeVzHfzAIWp20lpfHzsO9+fauqa+AXE+lydoDna392V/f29yJ/S35S7msQNNLEoTXC36fFXGoKK3f/zu0Bndtm96p8ZUW8soV7Tuc4H8zqGbZyo4t9e/Pg75yywjxx1HIbBZdT1eVXGo+VPOC9QFho6MaJo7pmwpJRB3K994zqLIOwjVP4vXv46/kuGSXUp1wVUjAIfEtUtWmzq9PjPRXe2JaYiVxk/pVE8H6oue03CDQHvEcE2sqZTB5e/vbi7csQcBwdE9KOT76YqVFk2dg/07i99v1gN/gPkQYz5VISAAA=
EOF
```
---------------------------------------------------------------------------
## Install [Microk8s]:
### 01. Install [microk8s] snap package
```sh
sudo snap install microk8s --classic
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
  - Note: applying manifest four times to compensate for CRD startup time
```
kubectl kustomize https://github.com/ContainerCraft/Kargo | kubectl apply -f -
sudo microk8s status --wait-ready && sleep 10
kubectl kustomize https://github.com/ContainerCraft/Kargo | kubectl apply -f -
```
---------------------------------------------------------------------------
## OPTIONAL:

### b. Install virtctl
```sh
export VIRTCTL_RELEASE=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases/latest | awk -F '["v,]' '/tag_name/{print $5}')
sudo curl --output /usr/local/bin/virtctl -L https://github.com/kubevirt/kubevirt/releases/download/v${VIRTCTL_RELEASE}/virtctl-v${VIRTCTL_RELEASE}-linux-amd64
sudo chmod +x /usr/local/bin/virtctl
```
### c. Create a test VM
  - Upload SSH Public Key for dynamic VM Injection
```sh
ls ~/.ssh/id_rsa.pub || ssh-keygen \
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
virtctl console -n kargo test
```
> Credentials: `ubuntu:ubuntu`
  - watch kargo events with this command

### Install OpenEBS for Storage
  - Used for configuring network bonds/bridges with kubernetes api yaml definitions
```sh
sudo microk8s enable openebs      && sudo microk8s status --wait-ready
```
### Enhance KVM kernel arguments in /etc/default/grub
  - Note: causes reboot
```sh
echo R1JVQl9ERUZBVUxUPTAKR1JVQl9USU1FT1VUPTAKR1JVQl9USU1FT1VUX1NUWUxFPWhpZGRlbgpHUlVCX0RJU1RSSUJVVE9SPWBsc2JfcmVsZWFzZSAtaSAtcyAyPiAvZGV2L251bGwgfHwgZWNobyBEZWJpYW5gCkdSVUJfQ01ETElORV9MSU5VWD0nY2dyb3VwX21lbW9yeT0xIGNncm91cF9lbmFibGU9Y3B1c2V0IGNncm91cF9lbmFibGU9bWVtb3J5IHN5c3RlbWQudW5pZmllZF9jZ3JvdXBfaGllcmFyY2h5PTAgaW50ZWxfaW9tbXU9b24gaW9tbXU9cHQgcmQuZHJpdmVyLnByZT12ZmlvLXBjaSBwY2k9cmVhbGxvYycK | base64 -d | sudo tee /etc/default/grub && sudo update-grub && sudo reboot
```

### Have fun experimenting with your new hypervisor!
  - [Example VM Definitions]

[microk8s]:https://microk8s.io
[Microk8s]:https://microk8s.io
[Example VM Definitions]:https://github.com/ContainerCraft/qubo/tree/main/wip