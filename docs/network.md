## Virtual Machine Network

↴ [virsh-nat-bridge][../bin/virsh-nat-bridge] adds a network configures to libvirt with following attributes:

* NAT Bridge `nbr0` connects virtual machine instances to the external network
* Default network **10.1.1.0/24**, MAC-addresses prefix **02:FF**
* Domain is called **devops.test**:

Use `start` to enable the network:

```bash
virsh-nat-bridge start
```

Check the configuration `status` of the network:

```bash
>>> virsh-nat-bridge status
Name:           nat_bridge
UUID:           4a366e23-178c-4c9d-b0de-4f1df3cfaaf0
Active:         yes
Persistent:     yes
Autostart:      yes
Bridge:         nbr0
```

### Usage

The configuration provides pre-defined list of tuples of a 
MAC and IP address pair with a corresponding hostname.

Use the `list` sub-command to show all pre-defined tuples:

```bash
>>> virsh-nat-bridge list | head
02:FF:0A:0A:06:05,lxdns01.devops.test,10.1.1.5
02:FF:0A:0A:06:06,lxdns02.devops.test,10.1.1.6
02:FF:0A:0A:06:07,lxcm01.devops.test,10.1.1.7
02:FF:0A:0A:06:08,lxcm02.devops.test,10.1.1.8
02:FF:0A:0A:06:09,lxcc01.devops.test,10.1.1.9
02:FF:0A:0A:06:0A,lxcc02.devops.test,10.1.1.10
02:FF:0A:0A:06:0B,lxrm01.devops.test,10.1.1.11
02:FF:0A:0A:06:0C,lxrm02.devops.test,10.1.1.12
02:FF:0A:0A:06:0D,lxb001.devops.test,10.1.1.13
02:FF:0A:0A:06:0E,lxb002.devops.test,10.1.1.14
```

Use the `lookup` sub-command to print the tuple for a single 
hostname:

```
>>> virsh-nat-bridge lookup lxdev01
lxdev01.devops.test 10.1.1.28 02:FF:0A:0A:06:1C
```

### Configuration

Print the default configuration with the `config` sub-command:

```bash
>>> virsh-nat-bridge config
```

The output represents the **XML notation** used to configure libvirt.

Options to the `virsh-nat-bridge` command allow to customise:

* The name of the network bridge (default `nbr0`)
* The DNS domain name (default `devops.test`)
* The MAC-address prefix (default `02:FF:0A:0A:06`)
* The IP-address prefix (default `10.1.1`)
* Hostnames in form of a list



