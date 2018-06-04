# Virtual Machine Images

In the following context the term virtual machine **image** refers to:

* A generic configuration of a virtual machine and its corresponding disk image stored in a sub-directory defined by the environment variable **`VM_IMAGE_PATH`**.
* A generic very basic Linux configuration (user accounts, network, etc.) common to the Linux deployed into the disk image.

Virtual machine images are used as **templates** to create virtual machine instances in a _reproducible_ way for development and testing.

## Installation

The [virt-install](https://virt-manager.org/) program creates a `disk.img` and start the installation program for a selected Linux distribution:

```bash 
## -- Debian 9 --
mkdir -p $VM_IMAGE_PATH/debian9 && cd $VM_IMAGE_PATH/debian9
virt-install --name debian9 --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
         --disk path=disk.img,size=40,format=qcow2,sparse=true,bus=virtio \
         --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8 serial' \
         --location http://deb.debian.org/debian/dists/stretch/main/installer-amd64/
## -- CentOS 7 --
virt-install --name centos7 --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
           --disk path=disk.img,size=100,format=qcow2,sparse=true,bus=virtio \
           --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8 serial' \
           --location http://mirror.centos.org/centos-7/7.3.1611/os/x86_64/
## -- ArchLinux --
mkdir -p $VM_IMAGE_PATH/arch && cd $VM_IMAGE_PATH/arch
wget -O arch.iso http://ftp-stud.hs-esslingen.de/pub/Mirrors/archlinux/iso/2018.06.01/archlinux-2018.06.01-x86_64.iso
virt-install --name arch --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
         --disk path=disk.img,size=40,format=qcow2,sparse=true,bus=virtio --cdrom arch.iso
```

During installation following configuration are required:

* Keymap: English
* Host name (e.g the distribution nick-name squeeze or lucid)
* Domain name `devops.test`
* Use the password "root" for the `root` account
* Create a user `devops` with password "devops"
* Single primary partition for `/` (no SWAP).

Install a minimal standard system, no desktop environment (unless really needed), no services, no development environment, no editor, nothing except a bootable Linux.

### Automation

Install a virtual machine image with [pressed](https://wiki.debian.org/DebianInstaller/Preseed) and the [Debian Installer](https://www.debian.org/releases/stable/amd64/ch06.html.en):

```bash
# install a Debian Jessie virtual machine image
>>> mkdir -p $VM_IMAGE_PATH/debian8 && cd $VM_IMAGE_PATH/debian8
>>> virt-install --name debian8 --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
             --disk path=disk.img,size=40,format=qcow2,sparse=true,bus=virtio \
             --location http://deb.debian.org/debian/dists/jessie/main/installer-amd64/ \
             --graphics none --console pty,target_type=serial --noreboot \
             --extra-args 'auto=true hostname=jessie domain=devops.test console=ttyS0,115200n8 serial' \
             --initrd-inject=$VM_TOOLS/var/debian/8/preseed.cfg
>>> virsh undefine debian8
# install a Debian Stretch virtual machine image
>>> mkdir -p $VM_IMAGE_PATH/debian9 && cd $VM_IMAGE_PATH/debian9
>>> virt-install --name debian9 --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
             --disk path=disk.img,size=40,format=qcow2,sparse=true,bus=virtio \
             --location http://deb.debian.org/debian/dists/stretch/main/installer-amd64/ \
             --graphics none --console pty,target_type=serial --noreboot \
             --extra-args 'auto=true hostname=stretch domain=devops.test console=ttyS0,115200n8 serial' \
             --initrd-inject=$VM_TOOLS/var/debian/9/preseed.cfg \
             --initrd-inject=$VM_TOOLS/var/debian/9/post-install.sh
>>> virsh undefine debian9
```

Find Debian pressed files in [var/debian/](../var/debian).

Install with CentOS/Fedora **Kickstart**:

```bash
>>> mkdir -p $VM_IMAGE_PATH/centos7 && cd $VM_IMAGE_PATH/centos7
>>> virt-install --name centos7 --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
             --disk path=disk.img,size=40,format=qcow2,sparse=true,bus=virtio \
             --location http://mirror.centos.org/centos-7/7/os/x86_64/ \
             --graphics none --console pty,target_type=serial --noreboot \
             --initrd-inject=$VM_TOOLS/var/centos/7/kickstart.cfg \
             --extra-args 'console=ttyS0,115200n8 serial \
                           inst.repo=http://mirror.centos.org/centos-7/7/os/x86_64/ \
                           inst.text inst.ks=file:/kickstart.cfg'
>>> virsh undefine centos7
```

Find the kickstart file in [var/centos](../var/centos).

### Permissions

The `virt-install` program may leave the disk images with the wrong permissions. 

The following command will adjust the permissions to all `disk.img` files in `VM_IMAGE_PATH`:

```bash
>>> sudo find $VM_IMAGE_PATH/ -name disk.img -exec chmod a+rw {} \;
```

## Customization

After the installation has finished the virtual machine image can be booted and customized.

```bash
# make sure that the working directory contains the disk image file
>>> cd $VM_IMAGE_PATH/debian8
>>> ls -1
disk.img
```

### Image Configuration

The ↴ [virsh-config](../bin/virsh-config) command creates a file called `libvirt_instance.xml` which contains the configuration required by libvirt to operate the virtual machine image. Similar the ↴ [ssh-config-instance](../bin/ssh-config-instance) command prepares the configuration file `ssh_config` and a SSH key-pair for login:

```bash
>>> virsh-config --vnc
Domain name lxdev01.devops.test with MAC-address 02:FF:0A:0A:06:1C
Using disk image with path: /srv/projects/vm-tools/vm/images/debian8/disk.img
Libvirt configuration: /srv/projects/vm-tools/vm/images/debian8/libvirt_instance.xml
>>> ssh-config-instance 
Password-less SSH key-pair create in /srv/projects/vm-tools/vm/images/debian8/keys
SSH configuration: /srv/projects/vm-tools/vm/images/debian8/ssh_config
>>> ls -1 
disk.img
keys/
libvirt_instance.xml
ssh_config
```

Use the libvirt configuration file to start the virtual machine image with the `virsh` command

```bash
>>> virsh create ./libvirt_instance.xml
Domain lxdev01.devops.test created from ./libvirt_instance.xml
# follwoing command allows to access the VNC graphical console (if required)
>>> virt-viewer lxdev01.devops.test
```

### Password-less Login

The ↴ [ssh-instance](../bin/ssh-instance) command allows login to and the execution of command in the virtual machine. Similar the ↴ [rsync-instance](..bin/rsync-instance) allow top copy file into and from the virtual machine. 

You may want to **install Sudo and Rsync** in the virtual machine unless this has been part of the basic OS deployment beforehand:

```bash
# install required packages on Debian Stretch
>>> ssh-instance "su -lc 'apt install rsync sudo'"  # login as devops, execute command as root user
# install required packages on CentOS
>>> ssh-instance -r 'yum install rsync sudo'
```

Use these tools to **enable password-less SSH login** to the virtual machine image for the users root and devops: 

```bash
# Sudo configuration for user devops
>>> ssh-instance "su -lc 'echo \"devops ALL = NOPASSWD: ALL\" > /etc/sudoers.d/devops'"
# paths for the SSH key
>>> ssh-instance 'mkdir -p -m 0700 /home/devops/.ssh ; sudo mkdir -p -m 0700 /root/.ssh'
# deploy the SSH key for password-less login
>>> rsync-instance keys/id_rsa.pub :.ssh/authorized_keys
>>> ssh-instance -s 'cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys'
# shutdown the virtual machine image
>>> ssh-instance -r "systemctl poweroff"
```
