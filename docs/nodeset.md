# Nodesets

↴ [var/aliases/vn.sh](../var/aliases/vn.sh) defines 
the `virsh-nodeset` command used to work on a set (group) of virtual machine
instances. 

It is based on the `nodeset` command from Clustershell:

<http://clustershell.readthedocs.io/en/latest/tools/nodeset.html>

```bash
>>> which vn
vn: aliased to virsh-nodeset
# show the help text
>>> vn h
virsh-nodeset <command>

Loops over a nodeset of VMs define by the $NODES environment variable.

command:
  c,  command <args>        execute a command in the path of each VM instance
                            ('{}' brackets interpolated with node FQDN)
  co, config <args>         write a libvirt configuration file (cf. virsh-config)
  ex, execute <args>        execute a command in each VM instance
  h,  help                  show this help text
  st, start                 start all VM instances
  sh, shutdown              shutdown all VM instances
  sh, shadow <image>        start VM instances using a template
  rd, redefine              shutdown, undefine, define, start VM instances
  rm, remove                remove all VM instances
  rs, restart               restart all VM instances
# define a nodeset environment variable
>>> export NODES=lxdev0[1,2]
# $NODES is used to create virtual machine instances
>>> vn s centos7
Domain lxdev01.devops.test definition file /srv/projects/vm-tools/vm/instances/lxdev01.devops.test/libvirt_instance.xml
SSH configuration: /srv/projects/vm-tools/vm/instances/lxdev01.devops.test/ssh_config
Domain lxdev02.devops.test definition file /srv/projects/vm-tools/vm/instances/lxdev02.devops.test/libvirt_instance.xml
SSH configuration: /srv/projects/vm-tools/vm/instances/lxdev02.devops.test/ssh_config
# execute a command in each virtual machine instance
>>> vn ex 'hostname ; uname -r'
-- lxdev01 --
lxdev01
3.10.0-693.21.1.el7.x86_64
-- lxdev02 --
lxdev02
3.10.0-693.21.1.el7.x86_64
# delete the virtual machine instances
>>> vn r                    
Domain lxdev01.devops.test destroyed
Domain lxdev01.devops.test has been undefined
Domain lxdev02.devops.test destroyed
Domain lxdev02.devops.test has been undefined
```
