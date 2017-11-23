
The file ↴ [var/aliases/vm.sh](var/aliases/vm.s) defines a wrapper script called **`vm`** with sue the more frequent commands more convenient:

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



