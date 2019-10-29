## Ansible

The ↴ [`ansible-instance`](../bin/ansible-instance) program writes an inventory to `ansible.ini`,
execute `ansible` for a given VM instance:

```bash
>>> vm shadow centos7 lxdev01
Domain lxdev01.devops.test definition file /home/vpenso/projects/vm-tools/vm/instances/lxdev01.devops.test/libvirt_instance.xml
SSH configuration: /home/vpenso/projects/vm-tools/vm/instances/lxdev01.devops.test/ssh_config
Domain lxdev01.devops.test defined from /home/vpenso/projects/vm-tools/vm/instances/lxdev01.devops.test/libvirt_instance.xml
Domain lxdev01.devops.test started
>>> vm cd lxdev01
# create the ansible inventory configuration
>>> ansible-instance -m ping
/home/vpenso/projects/vm-tools/vm/instances/lxdev01.devops.test/ansible.ini written.
lxdev01 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
# show the inventory configuration
>>> cat ansible.ini
lxdev01 ansible_user=root ansible_host=10.1.1.30 host_key_checking=no ansible_ssh_private_key_file=...
>>> ansible-instance --list-hosts
  hosts (1):
    lxdev01
# alternativly reference the inventory file and use the VM instance name
>>> ansible -i ansible.ini lxdev01 -a ls
lxdev01 | CHANGED | rc=0 >>
anaconda-ks.cfg
```

Execute an Ansible playbook [anply] in the VM instance:

```bash
cat > httpd.yaml <EOF
---
- hosts: lxdev01
  tasks:
    - name: ensure a list of packages installed
      yum:
        name: "{{ packages }}"
      vars:
        packages:
        - httpd
        - httpd-tools
EOF
```
```bash
ansible-playbook -i ansible.ini httpd.yaml
```


## References

[anply] Ansible - Intro to Playbooks  
https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html
