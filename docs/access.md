
The file ↴ [var/aliases/vm.sh](var/aliases/vm.s) defines a wrapper script called **`vm`** with sue the more frequent commands more convenient:

```bash
>>> vm                   
vm <command>

<command>
     cd <name>                change to the VM directory
 cl, clone <image> <name>     copy an VM image, and start VM instance
  c, create <file>            start VM instance from XML configuration
  d, define <file>            define a VM instance from an XML configuration
 ex, exec <name> <command>    execute a command in a VM instance
  h, shutdown <id|fqdn>       graceful shutdown a VM instance
  k, kill <id|fqdn>           destroy a VM instance
  i, image                    list available VM images
  l, list                     list all VM instances
 lo, login <name>             login into VM instance
  r, remove <name>            delete a VM instance
  p, path <name>              print path to VM instance
  s, shadown <image> <name>   shadow a VM image, and start VM instance
 st, start <id|fqdn>          start a defined VM instance
 sy, sync <name> <src> <dst>  rsync files to VM instance
  u, undefine <id|fqdn>       undefine VM instance
```

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
>>> vm login lxdev01                      # login
>>> vm exec lxdev01 'ip a | grep inet'    # execute a command
# list running virtual machine instance
>>> vm list
# shutdown virtual machine instance
>>> vm shutdown lxdev01
```
