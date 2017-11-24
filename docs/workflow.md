
The file ↴ [var/aliases/vm.sh](var/aliases/vm.s) defines a shell function called **`vm`** used as shorthand for frequent commands.

## Workflow

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
 Id    Name                           State
 ----------------------------------------------------
  1     lxdev01.devops.test            running
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

## Login

Login to a virtual machine using `ssh`:

```bash
# shorthand
>>> vm lo lxdev03
# is equivalent to
>>> virsh-instance login lxdev03
```

The above command will change into the directory with the specified virtual machine instance is located:

```
# shorthand
>>> vm cd lxdev03
# is equivalent to
>>> cd $(virsh-instance path lxdev03)
# is equivalent to using the environment variable with the virtual machine FQDN
>>> cd $VM_INSTANCE_PATH/lxdev03.devops.test
```

Afterwards it calls [ssh-exec](../bin/ssh-exex) with the `-r` option to **login as root user**:

* It will automatically read the configuration from `$PWD/ssh_config` (if present)
* The configuration references a SSH private key located in `$PWD/keys/id_rsa` used to login without password.

```
>>> ssh-exec -r
# configuration of a specific virtual machine instance
>>> cat ssh_config                          
Host instance
  User devops
  HostName 10.1.1.28
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  IdentityFile /srv/projects/vm-tools/vm/instances/lxdev01.devops.test/keys/id_rsa
```




