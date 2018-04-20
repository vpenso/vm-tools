This section introduces methods to configure a virtual machine instance
using **Salt SSH** from SaltStack as configuration management:

<https://docs.saltstack.com/en/latest/topics/ssh/>

The ↴ [salt-instance](../bin/salt-instance) program writes all environment 
file used to initialize the connection to a virtual machine instance:

```bash
# create a new virtual machine instance
>>> vm s centos7 lxdev02
Domain lxdev02.devops.test definition file /srv/projects/vm-tools/vm/instances/lxdev02.devops.test/libvirt_instance.xml
SSH configuration: /srv/projects/vm-tools/vm/instances/lxdev02.devops.test/ssh_config
Domain lxdev02.devops.test defined from /srv/projects/vm-tools/vm/instances/lxdev02.devops.test/libvirt_instance.xml
Domain lxdev02.devops.test started
# change into the directory of the virtual machine instance
>>> vm cd lxdev02.devops.test
# initialize the Salt SSH environment
>>> salt-instance              
/srv/projects/vm-tools/vm/instances/lxdev02.devops.test/Saltfile written.
/srv/projects/vm-tools/vm/instances/lxdev02.devops.test/salt/master written.
/srv/projects/vm-tools/vm/instances/lxdev02.devops.test/salt/roster written.
# run Salt SSH
>>> salt-ssh --no-host-keys instance cmd.run hostname
instance:
    lxdev02
```

The Salt configuration files will be added to the virtual machine instance directory:

```bash
>>> tree                                      
.
├── disk.img
├── keys
│   ├── id_rsa
│   └── id_rsa.pub
├── libvirt_instance.xml
├── salt
│   ├── master
│   └── roster
├── Saltfile
├── salt.log
└── ssh_config
```

`Saltfile` - Configuration of the `salt-ssh` command

<https://docs.saltstack.com/en/latest/topics/ssh/index.html#define-cli-options-with-saltfile>

`salt/roster` - Connection configuration for the virtual machine instance:

<https://docs.saltstack.com/en/latest/topics/ssh/roster.html#ssh-roster>

`salt/master` - `salt-ssh` read a couple of configuration items from the Salt master configuration

<https://docs.saltstack.com/en/latest/ref/configuration/index.html#master-configuration>

```bash
>>> tail -n+1 Saltfile salt/master salt/roster
==> Saltfile <==
salt-ssh:
  roster_file: ./salt/roster
  config_dir: ./salt
  ssh_log_file: ./salt.log
  ssh_max_procs: 10
  ssh_wipe: True
  ssh_rand_thin_dir: True
  ssh_sudo: True
  ssh_tty: True

==> salt/master <==
cachedir: /tmp/salt
pki_dir: /tmp/salt

==> salt/roster <==
instance:
  host: 10.1.1.29
  user: root
  priv: /srv/projects/vm-tools/vm/instances/lxdev02.devops.test/keys/id_rsa
```
