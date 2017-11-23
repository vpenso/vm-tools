# VM Tools

The tool-chain included in this repository allow a quick setup of virtual machines 
for development and testing on your Linux workstation.

The tool-chain is based on software available in all modern Linux distributions: 

* [KVM](http://www.linux-kvm.org)
* [Libvirt](http://libvirt.org/)
* [SSH](http://www.openssh.com/)
* [Rsync](http://rsync.samba.org/i)
* [SSHfs](http://fuse.sourceforge.net/sshfs.html)
* [Chef](https://wiki.opscode.com).


## Prerequisites 

Install following packages on Debian:

```bash
>>> sudo apt -y install libvirt-daemon-system libvirt-dev libvirt-clients \
                        virt-manager virt-viewer virt-top virtinst \
                        qemu-utils qemu-kvm libguestfs-tools ovmf
```

Install following package group on Fedora:

```bash
>>> sudo dnf -y install @virtualization
```

Enable your user to manage virtual machines (re-login to active these group rights):

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

## Environment

The shell script ↴ [source_me.sh](source_me.sh) adds the tool-chain in this repository to your shell environment:

```bash
>>> source source_me.sh
```

It will add the [bin/](bin/) sub-directory to your `PATH` and define several additional environment variables.

## Usage

The [docs/](docs) sub-directory includes all documentation required us this tool-chain:

* [images.md](docs/images.md) describes how to create re-usable virtual machine images.
