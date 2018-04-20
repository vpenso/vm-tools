# Nodesets

↴ [var/aliases/virsh-nodeset.sh](../var/aliases/virsh-nodeset.sh) defines 
the `virsh-nodeset` command used to operate a set of virtual machine
instances. It is based on the `nodeset` command from Clustershell:

<http://clustershell.readthedocs.io/en/latest/tools/nodeset.html>

↴ [nodeset-loop](../bin/nodeset-loop) command iterates over a given
list of node, aka virtual machines:

```bash
# define a nodeset environment variable
>>> export NODES=lxdev0[1,2]
# $NODES is used to create virtual machine instances
>>> virsh-nodeset shadow centos7
Domain lxdev01.devops.test definition file /srv/projects/vm-tools/vm/instances/lxdev01.devops.test/libvirt_instance.xml
SSH configuration: /srv/projects/vm-tools/vm/instances/lxdev01.devops.test/ssh_config
Domain lxdev02.devops.test definition file /srv/projects/vm-tools/vm/instances/lxdev02.devops.test/libvirt_instance.xml
SSH configuration: /srv/projects/vm-tools/vm/instances/lxdev02.devops.test/ssh_config
# execute a command in each virtual machine instance
>>> virsh-nodeset exec 'hostname ; uname -r'
-- lxdev01 --
lxdev01
3.10.0-693.21.1.el7.x86_64
-- lxdev02 --
lxdev02
3.10.0-693.21.1.el7.x86_64
# delete the virtual machine instances
>>> virsh-nodeset remove                    
Domain lxdev01.devops.test destroyed
Domain lxdev01.devops.test has been undefined
Domain lxdev02.devops.test destroyed
Domain lxdev02.devops.test has been undefined
```
