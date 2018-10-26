## Install

```bash
# check for hardware support
LC_ALL=C lscpu | grep Virtualization
# check kernel support
zgrep CONFIG_KVM /proc/config.gz
# Debian packages
sudo apt -y install \
       clustershell \
       libguestfs-tools \
       libvirt-clients \
       libvirt-daemon-system \
       libvirt-dev \
       ovmf \
       qemu-kvm \
       qemu-utils \
       ruby \
       virt-manager \
       virt-top \
       virt-viewer \
       virtinst
# Fedora/CentOS packages
sudo dnf -y install \
      @virtualization \
      clustershell
# ArchLinux packages
sudo pacman -Sy --noconfirm \
       bridge-utils \
       dnsmasq \
       ebtables \
       iptables \
       libvirt \
       openbsd-netcat \
       python-pip \
       ruby \
       vde2 \
       virt-install \
       virt-manager \
       virt-viewer \
       qemu \
       qemu-block-rbd
sudo pip install ClusterShell
```

Enable your user to manage virtual machines, **re-login** to activate these group rights:

```bash
>>> sudo usermod -a -G libvirt,kvm `id -un`      
```

Configure the libvirt service to run with your user ID (here illustrated with ID jdow):

```bash
>>> sudo grep -e '^user' -e '^group' /etc/libvirt/qemu.conf
user = "jdow"
group = "jdow"
# restart the Libvirt service daemon
>>> sudo systemctl restart libvirtd
```

For host access to guests on non-isolated, bridged networks, enable the libvirt NSS module:

```bash
>>> grep hosts /etc/nsswitch.conf
hosts: files libvirt ...
```

