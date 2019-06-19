# Virtual Machine Images

In the following context the term virtual machine **image** refers to:

* A generic configuration of a virtual machine and its corresponding disk image stored in a sub-directory defined by the environment variable **`VM_IMAGE_PATH`**.
* A generic very basic Linux configuration (user accounts, network, etc.) common to the Linux deployed into the disk image.

Virtual machine images are used as **templates** (golden images) to create virtual machine instances in a _reproducible_ way for development and testing.

# Installation

## Manual Installation

The [virt-install](https://virt-manager.org/) program creates a `disk.img` and start the installation program for a selected Linux distribution.

Boot the installer over HTTP:

```bash 
## -- Debian 9 --
mkdir -p $VM_IMAGE_PATH/debian9 && cd $VM_IMAGE_PATH/debian9
virt-install --name debian9 --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
         --disk path=disk.img,size=40,format=qcow2,sparse=true,bus=virtio \
         --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8 serial' \
         --location http://deb.debian.org/debian/dists/stretch/main/installer-amd64/
## -- Debian 10 --
mkdir -p $VM_IMAGE_PATH/debian10 && cd $VM_IMAGE_PATH/debian10
virt-install --name debian10 --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
         --disk path=disk.img,size=40,format=qcow2,sparse=true,bus=virtio \
         --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8 serial' \
         --location http://deb.debian.org/debian/dists/buster/main/installer-amd64/
## -- CentOS 7 --
mkdir -p $VM_IMAGE_PATH/centos7 && cd $VM_IMAGE_PATH/centos7
virt-install --name centos7 --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
           --disk path=disk.img,size=100,format=qcow2,sparse=true,bus=virtio \
           --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8 serial' \
           --location http://mirror.centos.org/centos-7/7/os/x86_64/
## -- Cern CentOS 7 --
mkdir -p $VM_IMAGE_PATH/cc7 && cd $VM_IMAGE_PATH/cc7
virt-install --name centos7 --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
           --disk path=disk.img,size=100,format=qcow2,sparse=true,bus=virtio \
           --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8 serial' \
           --location http://linuxsoft.cern.ch/cern/centos/7/os/x86_64/
```

Install from an CD ISO image:

```bash
## -- ArchLinux --
mkdir -p $VM_IMAGE_PATH/arch && cd $VM_IMAGE_PATH/arch
wget -O arch.iso http://ftp-stud.hs-esslingen.de/pub/Mirrors/archlinux/iso/2018.06.01/archlinux-2018.06.01-x86_64.iso
virt-install --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
             --disk path=disk.img,size=40,format=qcow2,sparse=true,bus=virtio \
             --name arch --cdrom arch.iso
## -- Debian (Sid) Testing - Daily Builds --
mkdir -p $VM_IMAGE_PATH/debian-testing && cd $VM_IMAGE_PATH/debian-testing
netinst=https://cdimage.debian.org/cdimage/daily-builds/daily/arch-latest/amd64/iso-cd/debian-testing-amd64-netinst.iso
wget -O debian.iso $netinst
virt-install --ram 2048 --os-type linux --virt-type kvm --network bridge=nbr0 \
             --disk path=disk.img,size=40,format=qcow2,sparse=true,bus=virtio \
             --name debian-testing --cdrom debian.iso
```

During installation following configuration are required:

* Keymap: English
* Host name (e.g the distribution nick-name squeeze or lucid)
* Domain name `devops.test`
* Use the password "root" for the `root` account
* Create a user `devops` with password "devops"
* Single primary partition for `/` (no SWAP).

Install a minimal standard system, no desktop environment (unless really needed), no services, no development environment, no editor, nothing except a bootable Linux.

To check the actual disk image size the following command can be used: `qemu-img info disk.img`.

## Automated Installation

### Debian with Preseed

Install a virtual machine image with [preseed](https://wiki.debian.org/DebianInstaller/Preseed) and the [Debian Installer](https://www.debian.org/releases/stable/amd64/ch06.html.en):

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

Find Debian preseed files in [var/debian/](../var/debian).

### CentOS/Fedora with Kickstart

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

## Permissions

The `virt-install` program may leave the disk images with the wrong permissions. 

The following command will adjust the permissions to all `disk.img` files in `VM_IMAGE_PATH`:

```bash
>>> sudo find $VM_IMAGE_PATH/ -name disk.img -exec chmod a+rw {} \;
```

# Customization

After the installation has finished the virtual machine image can be booted and customized.

```bash
# make sure that the working directory contains the disk image file
>>> cd $VM_IMAGE_PATH/debian8
>>> ls -1
disk.img
```

## Image Configuration

The ↴ [virsh-config](../bin/virsh-config) command creates a file called `libvirt_instance.xml` which contains the configuration required by libvirt to operate the virtual machine image:

```bash
>>> virsh-config --vnc
Domain name lxdev01.devops.test with MAC-address 02:FF:0A:0A:06:1C
Using disk image with path: /srv/projects/vm-tools/vm/images/debian8/disk.img
Libvirt configuration: /srv/projects/vm-tools/vm/images/debian8/libvirt_instance.xml
```

Similar the ↴ [ssh-config-instance](../bin/ssh-config-instance) command prepares the configuration file `ssh_config` and a SSH key-pair for login:

```bash
>>> ssh-config-instance 
Password-less SSH key-pair create in /srv/projects/vm-tools/vm/images/debian8/keys
SSH configuration: /srv/projects/vm-tools/vm/images/debian8/ssh_config
>>> ls -1 
disk.img
keys/
libvirt_instance.xml
ssh_config
```

Use the libvirt configuration file to start the virtual machine image with the `virsh` command:

```bash
>>> virsh create ./libvirt_instance.xml
Domain lxdev01.devops.test created from ./libvirt_instance.xml
# login as root from command line (prefered way of configuring the vm)
>>> vm lo lxdev01 -r
# alternatively access to the VNC graphical console is also possible
>>> vm v lxdev01
```

## Password-less Login

Depending on the installation you may need to add the `devops` user after the installation:

```bash
useradd -d /home/devops -m devops && passwd devops
```

The ↴ [ssh-instance](../bin/ssh-instance) command allows login to and the execution of command in the virtual machine. Similar the ↴ [rsync-instance](..bin/rsync-instance) allow top copy file into and from the virtual machine. 

You may want to **install Sudo and Rsync** in the virtual machine unless this has been part of the basic OS deployment beforehand:

```bash
# Debian (login as devops, execute command as root user)
ssh-instance "su -lc 'apt install rsync sudo haveged'"  
# CentOS
ssh-instance -r 'yum install rsync sudo'
# Arch
ssh-instance "su -lc 'pacman -S --noconfirm rsync sudo'"
```

Use these tools to **enable password-less SSH login** to the virtual machine image for the users root and devops: 

```bash
# Sudo configuration for user devops
ssh-instance "su -lc 'echo \"devops ALL = NOPASSWD: ALL\" > /etc/sudoers.d/devops'"
# paths for the SSH key
ssh-instance 'mkdir -p -m 0700 /home/devops/.ssh ; sudo mkdir -p -m 0700 /root/.ssh'
# deploy the SSH key for password-less login
rsync-instance keys/id_rsa.pub :.ssh/authorized_keys
ssh-instance -s 'cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys'
# shutdown the virtual machine image
ssh-instance -r "systemctl poweroff"
```

## DHCP

Following is optional for Debian based images.

Set the VM instance hostname during boot using information from DNS...

```bash
# install a hook script for the ISC DHCP version of Debian
rsync-instance -r $VM_TOOLS/var/debian/hostname :/etc/dhcp/dhclient-exit-hooks.d/hostname
# make sure the dependencies are installed
ssh-instance -r -- apt install -y hostname bind9-host coreutils sed
```

with a DHCP hook script [hostname](../var/debian/hostname)
