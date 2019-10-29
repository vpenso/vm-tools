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
       libnss-libvirt \
       libosinfo-bin \
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
       cpio \
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

## Libvirt NSS Module

For host access to guests on non-isolated, bridged networks, enable the [libvirt NSS module][01]:

```bash
>>> grep hosts /etc/nsswitch.conf
hosts: files libvirt libvirt_guest ...
>>> getent hosts lxdev01
10.1.1.30       lxdev01
```

Commands like `ssh` should work with VM instance names now:

```bash
>>> vm shadow ${image} lxdev01
>>> ssh -i $(vm path lxdev01)/keys/id_rsa devops@lxdev01
Last login: Tue Jul  9 11:42:57 2019 from gateway
[devops@lxdev01 ~]$
```

[01]: https://libvirt.org/nss.html
