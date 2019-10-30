
# Ansible

If the [Libvirt NSS modules](../INSTALL.md) is available:

```bash
# install Ansible on Debian
>>> sudo apt install -y ansible
# Enable the  host_list inventory plugin [ahlip]
>>> grep enable_plugins /etc/ansible/ansible.cfg
enable_plugins = host_list, advanced_host_list
```
```bash
# Get the list of availabe VM instance names
export NODES=$(virsh-nat-bridge list | cut -d, -f2 | cut -d. -f1 | nodeset -f | nodeset -e -S,)
# use an environment variable to consume the VM instances names
alias ansible='ansible -i "$NODES"'
# list the available inventory
ansible --list-hosts all
```
```bash
# create a VM instance and load its SSH private key
vm shadow ${image} lxdev02
ssh-add $(vm path lxdev02)/keys/id_rsa
# run a command in a VM instance
ansible -u root lxdev02 -a ls
```

### Ansible Instance Command

Without Libvirt NSS module use ↴ [`ansible-instance`](../bin/ansible-instance) 
to create an **inventory file** `ansible.ini` per VM instance:

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

Create a simple example playbook to install Apache

```bash
cat > httpd.yaml <<EOF
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

Execute an Ansible playbook [anply] in the VM instance:

```bash
ansible-playbook -i ansible.ini httpd.yaml
```


## References

[anply] Ansible - Intro to Playbooks  
https://docs.ansible.com/ansible/latest/user_guide/playbooks_intro.html

[ahlip] Ansible - Host List Inventory Plugin  
https://docs.ansible.com/ansible/latest/plugins/inventory/host_list.html
