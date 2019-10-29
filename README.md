# Virtual Machine Tools

The programs distributed within this repository enable users to quickly configure and **use virtual machines as development and test environment** on a Linux workstation. Programs in the [bin/](bin) sub-directory build a tool-chain to bootstrap multiple virtual machine instances in a very customizable way. 

The tool-chain is based on software available in all modern Linux distributions: 

* Linux [KVM](http://www.linux-kvm.org) is used as virtualization platform.
* [Libvirt][01] interfaces with KVM and manages the virtual machine network.
* [SSH](http://www.openssh.com/), [Rsync](http://rsync.samba.org/), and [SSHfs](http://fuse.sourceforge.net/sshfs.html) allows access the virtual machine instances.

**Make sure to [Install and configure Libvirt](INSTALL.md)**

Comprehensive examples:

* [OpenHPC Slurm Cluster with SaltStack](https://github.com/vpenso/saltstack-slurm-example) 
* [Apache Mesos Cluster with SaltStack](https://github.com/vpenso/mesos-example)
* [Lustre Parallel Filesystem with SaltStack](https://github.com/mtds/lustre_kvm_saltstack)

The shell script ↴ [source_me.sh](source_me.sh) adds the tool-chain in this repository to your shell environment:

```bash
>>> source source_me.sh
```

It will add the [bin/](bin/) sub-directory to your `PATH` and define several additional environment variables cf. [var/aliases/env.sh](var/aliases/env.sh).

## Usage

The [docs/](docs) sub-directory includes all documentation required to use this tool-chain:

* [docs/network.md](docs/network.md) explains the setup of the **virtual machine network**
* [docs/image.md](docs/image.md) describes how to create re-usable **virtual machine images** 
  (aka templates)
* [docs/instance.md](docs/instance.md) shows how to use VM images to create 
  any number of **virtual machine instances**, and how to configure the
  resources available to VM instance.
* [docs/workflow.md](docs/workflow.md) explains in great detail how to efficiently 
  interact with virtual machine instances. How to login, execute commands within
  a VM, copy file between host and the VM, and how to mount the VM root
  file-system.
* [docs/nodeset.md](docs/nodeset.md) exemplifies operation of multiple virtual 
  machine instance

Configure a virtual machine instance with a Configuration Management System:

* [docs/ansible.md](docs/ansible.md) show how to configure virtual machine
  instance with [Ansible](https://github.com/ansible/ansible). 
* [docs/chef.md](docs/chef.md) describes how to us the `chef-instance` command 
  to execute **Chef Solo** in a virtual machine instance.
* [docs/salt.md](docs/salt.md) describes how to create a configuration to use 
  **Salt SSH** with `salt-instance`

## License

Copyright 2012-2019 Victor Penso

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


[01]: http://libvirt.org
