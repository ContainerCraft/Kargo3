#!/bin/bash -x
GHUSER="usrbinkat"
LOCAL_USER="usrbinkat"
LOCAL_HOSTNAME="$(hostname)"
LOCAL_HOME="${HOME}"

run () {
 #start_qemu_guest_agent
  sshd_setup
  fedora
  basic
  extras
}

start_qemu_guest_agent () {
  sudo dnf update -y
  sudo dnf install -y qemu-guest-agent
  sudo systemctl enable --now qemu-guest-agent
}

sshd_setup () {
PUBKEYS="$(curl -L https://github.com/${GHUSER}.keys)"

  sudo dnf update -y
  sudo dnf install -y openssh-server
  sudo sed -i 's/^#PermitRootLogin\ prohibit-password/PermitRootLogin\ prohibit-password/g' /etc/ssh/sshd_config
  sudo systemctl enable --now sshd
  sudo systemctl restart sshd

  sudo mkdir -p  /root/.ssh                     /home/${LOCAL_USER}/.ssh 
  sudo touch     /root/.ssh/authorized_keys     ${LOCAL_HOME}/.ssh/authorized_keys
  sudo chmod 600 /root/.ssh/authorized_keys     ${LOCAL_HOME}/.ssh/authorized_keys

  sudo rm -rf /root/{anaconda-ks.cfg,original-ks.cfg}
  sudo echo ${PUBKEYS} >> /root/.ssh/authorized_keys
  sudo echo ${PUBKEYS} >> ${LOCAL_HOME}/.ssh/authorized_keys

  sudo chown ${LOCAL_USER}:${LOCAL_USER} -R ${LOCAL_HOME}
  sudo chown root:root                   -R /root
}

fedora () {

  sudo systemctl disable firewalld
  sudo systemctl stop swap-create@zram0
  sudo systemctl disable swap-create@zram0
  sudo touch /etc/systemd/zram-generator.conf

  sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
  sudo grubby --update-kernel=ALL --args 'setenforce=0 cgroup_memory=1 cgroup_enable=cpuset cgroup_enable=memory systemd.unified_cgroup_hierarchy=0 intel_iommu=on iommu=pt rd.driver.pre=vfio-pci pci=realloc'
 #grubby --update-kernel=ALL --args="noibrs noibpb nopti nospectre_v2 nospectre_v1 l1tf=off nospec_store_bypass_disable no_stf_barrier mds=off mitigations=off"
 #grubby --update-kernel=ALL --args="mitigations=off"

  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  sudo sed -i 's/$releasever/33/g' /etc/yum.repos.d/docker-ce.repo

  sudo dnf update -y
  sudo dnf remove -y podman container-selinux zram-generator-defaults
  sudo dnf -y install git socat ethtool ebtables iproute-tc conntrack-tools containerd.io docker-ce-cli docker-ce
 #sudo dnf -y install git socat ethtool ebtables iproute-tc conntrack-tools containerd.io docker-ce-cli

  systemctl enable --now docker
  systemctl enable --now containerd
  sudo systemctl enable containerd
  sudo systemctl enable docker

}

extras () {
  sudo dnf -y install vi vim tmux htop lnav glances neofetch
 #sudo dnf -y groupinstall "Container Management"
 #sudo dnf -y install @virtualization
 #sudo echo 'unix_sock_group = "libvirt"' > /etc/libvirt/libvirtd.conf
 #sudo echo 'unix_sock_rw_perms = "0770"' > /etc/libvirt/libvirtd.conf
 #sudo systemctl enable  libvirtd
 #sudo usermod -aG libvirt ${LOCAL_USER}
}

basic () {
  sudo hostnamectl set-hostname ${LOCAL_HOSTNAME}
  sudo git clone https://github.com/containercraft/artemis.git /root/artemis
}

run
