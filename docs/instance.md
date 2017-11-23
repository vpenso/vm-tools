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

A source virtual machine image can be used as template for a virtual machine instance with **two modes**:

1. Create a `clone` of the original disk image **without any association** to the original.
2. Create a `shadow` of the original disk image keeping an association **storing only the delta difference**.

Create a shadow of a virtual machine image and use it to **start a new virtual machine instance** with the name `lxdev01.devops.test`:

```bash
>>> virsh-instance shadow debian8 lxdev01                                       
Domain name lxdev01.devops.test with MAC-address 02:FF:0A:0A:06:1C
Using disk image with path: /srv/projects/vm-tools/vm/instances/lxdev01.devops.test/disk.img
Libvirt configuration: /srv/projects/vm-tools/vm/instances/lxdev01.devops.test/libvirt_instance.xml
SSH configuration: /srv/projects/vm-tools/vm/instances/lxdev01.devops.test/ssh_config
Domain lxdev01.devops.test defined from /srv/projects/vm-tools/vm/instances/lxdev01.devops.test/libvirt_instance.xml
Domain lxdev01.devops.test started
```

This will create a new sub-directory under `VM_INSTANCE_PATH` with the required configuration for libvirt and SSH:

```bash
>>> ls -1 $VM_INSTANCE_PATH/lxdev01.devops.test    
disk.img
keys/
libvirt_instance.xml
ssh_config
# or..
>>> tree $(virsh-instance path lxdev01)
/srv/projects/vm-tools/vm/instances/lxdev01.devops.test
├── disk.img
├── keys
│   ├── id_rsa
│   └── id_rsa.pub
├── libvirt_instance.xml
└── ssh_config
```

Use the `login` sub-command to **SSH into the virtual machine instance**:

```bash
>>> virsh-instance login lxdev01                  
root@lxdev01:~# exit
```

Shutdown and **remove the virtual machine instance** with the `remove` sub-command:

```bash
>>> virsh-instance remove lxdev01
Domain lxdev01.devops.test destroyed
Domain lxdev01.devops.test has been undefined
```

