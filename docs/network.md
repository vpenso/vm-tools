## Virtual Machine Network

↴ [virsh-nat-bridge](../bin/virsh-nat-bridge) adds a virtual network configuration to libvirt with following attributes:

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

The default configuration provides a pre-defined list of **tuples for 
MAC- and IP-address pairs with a corresponding hostname**. These are 
used to configure network for the virtual machine instances.

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

### Port Forwarding

By default, VMs are instantied on a closed network which is shielded from the LAN via NAT.

It is possible to allow connections to a particular port on a VM, thus opening a service running on top of it to the rest of the LAN. __Port forwarding__ is the process of forwarding requests for a specific port to another host, network, or port. As this process modifies the destination of the packet in-flight, it is considered a type of NAT operation.

**SECURITY NOTICE**: The following procedure will basically 'punch holes' on the local firewall of the KVM host (IPTables) and allows external connections from the LAN. It is assumed that the internal network where the KVM host is running is reasonable safe from the network security point of view (e.g. isolated from direct connection from the Internet). If it's not the case or you plan to attach the KVM host directly to the Internet, the following procedure can put your network security in peril. __You have been warned__.

``vm-tools`` provides a Ruby script to perform this operation, called ↴ [virsh-instance-port-forward](../bin/virsh-instance-port-forward). **NOTE**: in order to be executed this script requires that your user has __sudo__ privileges.

Forward SSH connections to a VM on local host port:
```bash
>>> virsh-instance-port-forward a lxdev01:22 2222
NAT rules:
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:2222 to:10.1.1.28:22
Forward rules:
ACCEPT     tcp  --  0.0.0.0/0            10.1.1.28            tcp dpt:2222
```

**NOTE**: whenever a rule is added, the script will automatically remove identical rules which were previously set in order to avoid duplicates.

Remove the rules from IPtables:
```bash
>>> virsh-instance-port-forward d lxdev01:22 2222
NAT rules:

Forward rules:

```

Shows IPtables rules (as noted at the beginning of this document, the default network created by ``vm_tools`` is **10.1.1.0/24**):
```bash
>>> virsh-instance-port-forward l
NAT rules:
DNAT        tcp  --  0.0.0.0/0           0.0.0.0/0             tcp dpt:2222 to:10.1.1.28:22
MASQUERADE  tcp  --  10.1.1.0/24         !10.1.1.0/24          masq ports: 1024-65535
MASQUERADE  udp  --  10.1.1.0/24         !10.1.1.0/24          masq ports: 1024-65535
MASQUERADE  all  --  10.1.1.0/24         !10.1.1.0/24
Forwarding:
ACCEPT     tcp  --  0.0.0.0/0            10.1.1.28            tcp dpt:22
ACCEPT     all  --  0.0.0.0/0            10.1.1.0/24          state RELATED,ESTABLISHED
ACCEPT     all  --  10.1.1.0/24          0.0.0.0/0 
```

Note that the output may change in relation to the number of active rules on the KVM host.

### Under the hood

What the ``virsh-instance-port-forward`` is doing can be accomplished directly using IPtables commands. The following steps will have the same result as before (note that __sudo__ privileges are still needed):

Forward SSH connections to a VM on local host port:
```bash
# Get the IP address of the VM:
>>> VM_IP=`vm ip lxdev01`
>>> sudo iptables -A PREROUTING -t nat -i enp5s0 -p tcp --dport 2222 -j DNAT --to $VM_IP:22
>>> sudo iptables -I FORWARD 1 -p tcp -d $VM_IP --dport 22 -j ACCEPT
```

Remove the rules from IPtables:
```bash
>>> sudo iptables -D PREROUTING -t nat -i enp5s0 -p tcp --dport 2222 -j DNAT --to $VM_IP:22
>>> sudo iptables -D FORWARD -p tcp -d $VM_IP --dport 22 -j ACCEPT
```

Shows IPtables rules:
```bash
>>> echo "NAT rules:"; sudo iptables -L -n -t nat | grep 10.1.1 
DNAT        tcp  --  0.0.0.0/0           0.0.0.0/0             tcp dpt:2222 to:10.1.1.28:22
MASQUERADE  tcp  --  10.1.1.0/24         !10.1.1.0/24          masq ports: 1024-65535
MASQUERADE  udp  --  10.1.1.0/24         !10.1.1.0/24          masq ports: 1024-65535
MASQUERADE  all  --  10.1.1.0/24         !10.1.1.0/24

>>> echo "Forwarding:"; sudo iptables -L FORWARD -n | grep 10.1.1
Forwarding:
ACCEPT     tcp  --  0.0.0.0/0            10.1.1.28            tcp dpt:22
ACCEPT     all  --  0.0.0.0/0            10.1.1.0/24          state RELATED,ESTABLISHED
ACCEPT     all  --  10.1.1.0/24          0.0.0.0/0 
```

**Network Interface name**: on a reasonable modern version of Linux, systemd/udev will automatically assign predictable, stable network interface names for all local Ethernet, WLAN and WWAN interfaces. In the example above, the name used ``enp5s0`` represent the first ethernet network card (``en`` stands for Ethernet, ``p`` is the bus number of the card and ``s`` is the slot number). Further info are [available here](https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/).

```bash
# Shows all network connections:
>>> ip a
[...]
2: enp5s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:AA:BB:CC:DD:EE brd ff:ff:ff:ff:ff:ff
        inet 10.2.1.1/24 brd 10.2.1.255 scope global enp5s0
[...]
```

### References

* [IPtables official web-site](https://netfilter.org/projects/iptables/index.html)
* [Netfilter/IPtables HOWTOs (official page)](https://netfilter.org/documentation/index.html#documentation-howto)
* [IPtables docs from Arch Wiki](https://wiki.archlinux.org/index.php/iptables)
* [An in-depth guide to IPtables, the Linux Firewall (Boolean World)](https://www.booleanworld.com/depth-guide-iptables-linux-firewall/)

