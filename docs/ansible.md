## Ansible

The ↴ [`ansible-instance`] program writes `ansible,ini` to the VM instance
directory and execute `ansible`

```bash
>>> vm shadow centos7 lxdev01
Domain lxdev01.devops.test definition file /home/vpenso/projects/vm-tools/vm/instances/lxdev01.devops.test/libvirt_instance.xml
SSH configuration: /home/vpenso/projects/vm-tools/vm/instances/lxdev01.devops.test/ssh_config
Domain lxdev01.devops.test defined from /home/vpenso/projects/vm-tools/vm/instances/lxdev01.devops.test/libvirt_instance.xml
Domain lxdev01.devops.test started
>>> vm cd lxdev01
>>> ansible-instance -m ping
/home/vpenso/projects/vm-tools/vm/instances/lxdev01.devops.test/ansible.ini written.
lxdev01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
>>> ansible-instance --list-hosts
  hosts (1):
    lxdev01
# alternativly reference the inventory file and use the VM instance name
>>> ansible -i ansible.ini lxdev01 -a ls
lxdev01 | CHANGED | rc=0 >>
anaconda-ks.cfg
```
