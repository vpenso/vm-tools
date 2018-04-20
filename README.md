# Virtual Machine Tools

The programs distributed within this repository enable users to quickly configure and **use virtual machines as development and test environment** on a Linux workstation. Programs in the [bin/](bin) sub-directory build a tool-chain to bootstrap many virtual machine instances in a very customizable way. 

The tool-chain is based on software available in all modern Linux distributions: 

* Linux [KVM](http://www.linux-kvm.org) is used as virtualization platform.
* [Libvirt](http://libvirt.org/) is used as generic interface on top of KVM, and to manage the virtual machine network.
* [SSH](http://www.openssh.com/), [Rsync](http://rsync.samba.org/), and [SSHfs](http://fuse.sourceforge.net/sshfs.html) allows access the virtual machine instances.

## Prerequisites 

**Debian** packages required:


```bash
>>> sudo apt -y install \
  libvirt-daemon-system libvirt-dev libvirt-clients \
  virt-manager virt-viewer virt-top virtinst clustershell \
  qemu-utils qemu-kvm libguestfs-tools ovmf ruby 
```

**Fedora/CentOS** packages required:

```bash
>>> sudo dnf -y install @virtualization clustershell
```

### Configuration

Enable your user to manage virtual machines (re-login to activate these group rights):

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

### Environment

The shell script ↴ [source_me.sh](source_me.sh) adds the tool-chain in this repository to your shell environment:

```bash
>>> source source_me.sh
```

It will add the [bin/](bin/) sub-directory to your `PATH` and define several additional environment variables cf. [var/aliases/env.sh](var/aliases/env.sh).

## Usage

The [docs/](docs) sub-directory includes all documentation required to us this tool-chain:

* [docs/network](docs/network.md) explains the setup of the **virtual machine network**
* [docs/image](docs/image.md) describes how to create re-usable **virtual machine images** 
  (aka templates)
* [docs/instance](docs/instance.md) shows how to use virtual machine images to create 
  any number of **virtual machine instances** for development and testing
* [docs/workflow](docs/workflow.md) explains in great detail how to efficiently 
  interact with virtual machine instances
* [docs/nodeset.md](docs/nodeset.md) exemplifies operation of multiple virtual 
  machine instance

### Provisioning

Configure a virtual machine instance with a Configuration Management System:

* [docs/chef.md](docs/chef.md) describes how to us the `chef-instance` command 
  to execute `chef-client` in a virtual machine instance.
* [docs/salt.md](docs/salt.md) describes how to create a configuration to use 
  Salt SSH with `salt-instance`

Find a comprehensive example using this tool-chain with [SaltStack](https://docs.saltstack.com) at:

<https://github.com/vpenso/saltstack-slurm-example>

# License

Copyright 2012-2018 Victor Penso

This is free software: you can redistribute it
and/or modify it under the terms of the GNU General Public
License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any
later version.

This program is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public
License along with this program. If not, see 
<http://www.gnu.org/licenses/>.

