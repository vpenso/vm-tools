# Instances

The tool ↴ [virsh-instance](../bin/virsh-instance) creates new **virtual machine instances**:

* A virtual machine instance is derived from a virtual machine image.
* Each virtual machine instance uses a dedicated [network](network.md) configuration.
* The virtual machine instance configuration and the disk image is deployed into a sub-directory of the path defined by the environment variable `VM_INSTANCE_PATH`

## Usage

The [image](image.md) document describes how to install virtual machine image templates.

List the available virtual machine images:

```bash
>>> virsh-instance list    
Images in /srv/projects/vm-tools/vm/images:
  debian8
  debian9
  centos7
```

A source virtual machine image can be used as template for a virtual machine instance with two methods:

1. Create a `clone` of the original disk image without any association to the original.
2. Create a `shadow` of the original disk image keeping an association storing only the delta difference.

### Start

Start a **virtual machine instance** with the name `lxdev03`:

```bash
## start a virtual machine instance
>>> virsh-instance shadow debian9 lxdev03
Domain name lxdev03.devops.test with MAC-address 02:FF:0A:0A:06:1E
Using disk image with path: /srv/vms/instances/lxdev03.devops.test/disk.img
Libvirt configuration: /srv/vms/instances/lxdev03.devops.test/libvirt_instance.xml
SSH configuration: /srv/vms/instances/lxdev03.devops.test/ssh_config
Domain lxdev03.devops.test defined from /srv/vms/instances/lxdev03.devops.test/libvirt_instance.xml
Domain lxdev03.devops.test started
```

### Cycle

Resources create for the virtual machine instance:

```bash
## directory of the VM instance
>>> virsh-instance path lxdev03
/srv/vms/instances/lxdev03.devops.test
## contents
>>> tree $(virsh-instance path lxdev03)       
/srv/vms/instances/lxdev03.devops.test
├── disk.img
├── keys
│   ├── id_rsa
│   └── id_rsa.pub
├── libvirt_instance.xml
└── ssh_config
## differential disk image (shadow image)
>>> ls -lh $(virsh-instance path lxdev03)/disk.img
-rw-r--r--. 1 root root 3.0M Oct 10 14:50 /srv/vms/instances/lxdev03.devops.test/disk.img
## delete the VM instance
>>> virsh-instance remove lxdev03
Domain lxdev03.devops.test destroyed
Domain lxdev03.devops.test has been undefined
```

### Login

```bash
## login as root user
>>> virsh-instance login lxdev03
## execute a command in the VM instance 
>>> virsh-instance exec lxdev03 'ip a | grep inet'
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
    inet 10.1.1.30/24 brd 10.1.1.255 scope global ens3
    inet6 fe80::ff:aff:fe0a:61e/64 scope link 
## rsync a file into the virtual machine
>>> virsh-instance sync lxdev03 /bin/bash :/tmp
sending incremental file list
bash

sent 1,137,020 bytes  received 35 bytes  2,274,110.00 bytes/sec
total size is 1,136,624  speedup is 1.00
```
