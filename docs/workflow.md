
The file ↴ [var/aliases/vm.sh](var/aliases/vm.s) defines a shell function called **`vm`** used as shorthand for frequent operation for multiple virtual machine instances.

# Workflow

The following command sequence represents a typical workflow with a virtual machine instance:

```bash
# list the available virtual machine images
>>> vm image
Images in /srv/projects/vm-tools/vm/images:
  debian8
  debian9
  centos7
# start a virtual machine instance
>>> vm shadow debian8 lxdev01
## ... work with the virtual machine instance
>>> vm login lxdev01                      # login as root
>>> vm exec lxdev01 'ip a | grep inet'    # execute a command
# list running virtual machine instance
>>> vm list
lxdev01.devops.test
# shutdown virtual machine instance
>>> vm shutdown lxdev01
Domain lxdev01.devops.test is being shutdown
# star the virtual machine instance
>>> vm start lxdev01
Domain lxdev01.devops.test started
## ... work with the virtual machine instance
# remove the virtual machine instance from the configuration
>>> vm remove lxdev01
Domain lxdev01.devops.test destroyed
Domain lxdev01.devops.test has been undefined
```

The following sections describe the steps illustrated above in more detail.

## Login

**Login to a virtual machine** using the following commands:

```bash
# shorthand
>>> vm lo lxdev03
# is equivalent to
>>> virsh-instance login lxdev03
```

Transparent to the user the above commands will change into the directory containing the specific virtual machine instance:

```bash
# shorthand
>>> vm cd lxdev03
# is equivalent to
>>> cd $(virsh-instance path lxdev03)
# is equivalent to using the environment variable with the virtual machine FQDN
>>> cd $VM_INSTANCE_PATH/lxdev03.devops.test
```

Afterwards it calls ↴ [ssh-exec](../bin/ssh-exec) with the `-r` option to **login as root user**:

* It will automatically read the configuration from `$PWD/ssh_config` (if present).
* The configuration references a SSH private key located in `$PWD/keys/id_rsa` used to login without password.
* Note that the SSH configuration file is generated automatically with ↴  [ssh-instance](../bin/ssh-instance) 

```bash
>>> ssh-exec -r
root@lxdev03:~# exit
exit
# configuration of a specific virtual machine instance
>>> cat $PWD/ssh_config                          
Host instance
  User devops
  HostName 10.1.1.28
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  IdentityFile /srv/projects/vm-tools/vm/instances/lxdev01.devops.test/keys/id_rsa
```

Given the configuration above, the login with `ssh-exec -r` basically executes following command:

```bash
>>> ssh -gt -F $PWD/ssh_config -l root instance /usr/bin/env bash
```

By default ↴ [ssh-exec](../bin/ssh-exec) without options performs a **login as the user devops**:

```bash
>>> ssh-exec                                                     
devops@lxdev03:~$ exit
exit
# login as devops, and execute sudo
>>> ssh-exec -s                                                       
root@jessie:/home/devops# exit
exit
```

Additionally option `-s` allows to **login as devops and executes `sudo`**.

## Execute Commands

The sub-command **`exec` will run a command** given by argument on a specified virtual machine:

```bash
# shorthand
>>> vm exec lxdev03 'uptime ; uname -a '
 09:54:39 up 16:48,  1 user,  load average: 0.00, 0.00, 0.00
 Linux lxdev03 3.16.0-4-amd64 #1 SMP Debian 3.16.43-2+deb8u5 (2017-09-19) x86_64 GNU/Linux
# is equivalent to
>>> virsh-instance exec lxdev03 'cat /etc/sudoers.d/devops '
 devops ALL = NOPASSWD: ALL
```

As described in the previous section the above commands execute `ssh-exec`:

```bash
>>> vm cd lxdev03
# execute a command as default user
>>> ssh-exec whoami
devops
# login as devops and exeute a command with sudo
>>> ssh-exec -s whoami                                                
root
# multple commands with sudo...
>>> ssh-exec -s 'apt install -qy zsh' && ssh-exec -s '/usr/bin/env zsh'
# pipes work as expected
>>> ssh-exec -r 'cat /etc/passwd' | grep ^devops
devops:x:1000:1000:devops,,,:/home/devops:/bin/bash
# input pipe redirection 
>>> echo text | ssh-exec 'cat - > /tmp/input.txt' && ssh-exec 'cat /tmp/input.txt'
text
```

## Copy Files

The sub-command **`sync` allows to copy files from and to a virtual machine**:

```bash
## copy a file from the host to a virtual machine instance
>>> vm sy lxdev03 /etc/hostname :/tmp/
# is equivalent to
>>> virsh-instance sync lxdev03 :/tmp/bash /tmp/
## copy a file from the virtual machine to the host
>>> vm sy lxdev03 :/etc/hostname /tmp
# is equivalent to
>>> virsh-instance sync lxdev03 :/etc/hostname /tmp
```

Note that colon `:` prefixes the path within the virtual machine.

In contrast to the previous sections here the ↴ [ssh-sync](../bin/ssh-sync) program is used:

* Like `ssh-exec` it will read `$PWD/ssh_config` (if present).
* The program is a **wrapper around the `rsync` program**, hence it is able to sync directory trees recursively also.

```bash
# change to the virtual machine instance directory
>>> vm cd lxdev03
# run rsync as user root and copy the /var/log directory from the virtual machine instance
>>> ssh-sync -r :/var/log .
>>> tree log/ | head
log/
├── alternatives.log
├── apt
│   ├── history.log
│   └── term.log
├── auth.log
├── btmp
├── daemon.log
├── debug
├── dmesg
```

Using `ssh-sync -r` is internally executing `rsync` similar to:

```bash
>>> RSYNC_RSH=ssh -q -F $PWD/ssh_config -l root
>>> rsync --omit-dir-times --recursive --copy-links --copy-dirlinks --delete --verbose instance:/var/log .
```

## Mount

The ↴ [sshfs-instance](../bin/sshfs-instance) command is used to mount a parts of the virtual machine file-system:

```bash
# change to the virtual machine instance directory
>>> vm cd lxdev03
# mount the entire root-filesystem to the mnt/ sub-directory
>>> sshfs-instance mount
:/ mounted to mnt/
>>> ls mnt 
bin/  boot/  dev/  etc/  home/  initrd.img@  lib/  lib64/  lost+found/  media/  mnt/  opt/  proc/  root/  run/  sbin/  srv/  sys/  tmp/  usr/  var/  vmlinuz@
>>> sshfs-instance umount
# mount a specified directory as user root
>>> sshfs-instance -r mount /var/log 
:/var/log mounted to mnt/
>>> sshfs-instance umount
```

The `sshfs-instance` command is internally executing `sshfs` similar to:

```bash
>>> sshfs -o idmap=user -o allow_root -F $PWD/ssh_config root@instance:/ mnt/
```

