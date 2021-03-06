
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
# login as devops
>>> vm login lxdev03
# login as devops run sudo
>>> vm login lxdev03 -s
# login as root
>>> vm login lxdev03 -r
```

The commands above will change into the directory containing the specific virtual machine instance:

```bash
# shorthand
>>> vm cd lxdev03
# is equivalent to
>>> cd $(virsh-instance path lxdev03)
# is equivalent to using the environment variable with the virtual machine FQDN
>>> cd $VM_INSTANCE_PATH/lxdev03.devops.test
```

Afterwards ↴ [ssh-instance](../bin/ssh-instance) is executed:

* It will automatically read the configuration from `$PWD/ssh_config` (if present).
* The configuration references a SSH private key located in `$PWD/keys/id_rsa` used to login without password.
* Note that the SSH configuration file is generated automatically with ↴  [ssh-config-instance](../bin/ssh-config-instance) 

```bash
>>> ssh-instance -r
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

Given the configuration above, the login with `ssh-instance -r` basically executes following command:

```bash
>>> ssh -gt -F $PWD/ssh_config -l root instance /usr/bin/env bash
```

By default ↴ [ssh-instance](../bin/ssh-instance) without options performs a **login as the user devops**:

```bash
>>> ssh-instance                  
devops@lxdev03:~$ exit
exit
# login as devops, and execute sudo
>>> ssh-instance -s                                                       
root@jessie:/home/devops# exit
exit
```

Additionally option `-s` allows to **login as devops and executes `sudo`**.

## Execute Commands

The sub-command **`exec` will run a command** given by argument on a specified virtual machine:

```bash
# login as user devops
>>> vm exec lxdev03 whoami  
devops
# use quotes to execute multiple commands
>>> vm exec lxdev03 whoami ; pwd
devops
/home/vpenso
>>> vm exec lxdev03 'whoami ; pwd'  
devops
/home/devops
# login as user devops, run command with sudo  
>>> vm exec lxdev03 -s 'whoami ; pwd'
root
/home/devops
# login as user root
>>> vm exec lxdev03 -r 'whoami ; pwd'
root
/root
```

As described in the previous section the above commands execute `ssh-instance`:

```bash
>>> vm cd lxdev03
# execute a command as default user
>>> ssh-instance whoami
devops
# login as devops and exeute a command with sudo
>>> ssh-instance -s whoami                                                
root
# multiple commands with sudo...
>>> ssh-instance -s 'apt install -qy zsh' && ssh-instance -s '/usr/bin/env zsh'
# pipes work as expected
>>> ssh-instance -r 'cat /etc/passwd' | grep ^devops
devops:x:1000:1000:devops,,,:/home/devops:/bin/bash
# input pipe redirection 
>>> echo text | ssh-instance 'cat - > /tmp/input.txt' && ssh-instance 'cat /tmp/input.txt'
text
```

Make sure to use a **double dash** `--` if options need to be passed to the commands executed in the virtual machine instance:

```bash
# the option parser presents an error message
>>> vm exec lxdev01 -r ls -l /etc/profile.d/
getopt: invalid option -- 'l'
...
# use dashs to protect the -l option to ls
>>> vm exec lxdev01 -r -- ls -l /etc/profile.d/
...
```

Make sure to handle globbing in your shell:

```bash
# use qoutation
>>> vm exec lxcm01 -r -- ls -l '/etc/profile.d/*.sh'
# or disable globbing
>>> noglob vm exec lxcm01 -r -- ls -l /etc/profile.d/*.sh
```


## Copy Files

The sub-command **`sync` allows to copy files from and to a virtual machine**:

```bash
## copy a file from the host to a virtual machine instance
>>> vm sync lxdev03 /etc/hostname :/tmp/
## copy a file from the virtual machine to the host
>>> vm sync lxdev03 :/etc/hostname /tmp
```

Note that colon `:` prefixes the path within the virtual machine.

In contrast to the previous sections here the ↴ [rsync-instance](../bin/rsync-instance) program is used:

* Like `ssh-instance` it will read `$PWD/ssh_config` (if present).
* The program is a **wrapper around the `rsync` program**, hence it is able to sync directory trees recursively also.

```bash
# change to the virtual machine instance directory
>>> vm cd lxdev03
# run rsync as user root and copy the /var/log directory from the virtual machine instance
>>> rsync-instance -r :/var/log .
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

Using `rsync-instance -r` is internally executing `rsync` similar to:

```bash
>>> RSYNC_RSH=ssh -q -F $PWD/ssh_config -l root
>>> rsync --omit-dir-times --recursive --copy-links --copy-dirlinks --delete --verbose instance:/var/log .
```

## Mount

Mount a directory from the virtual machine instance with the `mount` sub-command:

```bash
# mount the file-system root / directory from the virtual machine instance
>>> vm mount lxdev03                       
:/ mounted to mnt/
## ... work with the mount point ...
>>> vm cd lxdev03 && ls mnt/home 
devops/
# umount the the virtual machine instance
>>> vm umount lxdev03
# mount a sub-directory as user root
>>> vm umount lxdev03 -r /home/devops
```

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

