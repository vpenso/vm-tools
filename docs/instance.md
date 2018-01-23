# Instances

The ↴ [virsh-instance](../bin/virsh-instance) program creates new **virtual machine instances**:

* A virtual machine instance is derived from a virtual machine image (cf. [image](image.md)).
* Each virtual machine instance uses a dedicated network configuration (cf. [network](network.md)).
* The virtual machine instance configuration and the disk image is deployed into a sub-directory of the path defined by the environment variable **`VM_INSTANCE_PATH`**.

## Usage

List the available **virtual machine images**:

```bash
>>> vm image
Images in /srv/projects/vm-tools/vm/images:
  debian8
  debian9
  centos7
```

Virtual machine images are used as template for virtual machine instances in **two modes**:

1. Create a **`clone`** of the original disk image **without any association** to the original.
2. Create a **`shadow`** of the original disk image keeping an association **storing only the delta difference**.

Create a shadow of a virtual machine image and use it to **start a new virtual machine instance**:

```bash
>>> vm shadow debian8 lxdev01
Domain name lxdev01.devops.test with MAC-address 02:FF:0A:0A:06:1C
Using disk image with path: /srv/vms/instances/lxdev01.devops.test/disk.img
Libvirt configuration: /srv/vms/instances/lxdev01.devops.test/libvirt_instance.xml
SSH configuration: /srv/vms/instances/lxdev01.devops.test/ssh_config
Domain lxdev01.devops.test defined from /srv/vms/instances/lxdev01.devops.test/libvirt_instance.xml
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
>>> vm login lxdev01                  
root@lxdev01:~# exit
```

Shutdown and **remove the virtual machine instance** with the `remove` sub-command:

```bash
>>> vm remove lxdev01
Domain lxdev01.devops.test destroyed
Domain lxdev01.devops.test has been undefined
```

