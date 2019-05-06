#
# Copyright 2013-2017 Victor Penso
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

function virsh-instance-undefine() {
        local vm=$(virsh-instance fqdn $1)
        # is the VM instance defined?
        if virsh list --all --name --persistent | grep -sq $vm ; then
                virsh undefine $vm | sed '/^$/d'
        fi
}

VM_FUNCTION_HELP="\
vm <command> 

<command>
 cd  <name>                   change to an instance directory
 c , create <file>            start instance from XML configuration
 cl, clone <image> <name>     copy image, and start instance
 co, config <name> <args>     configure instance (cf. virsh-config)
 d , define <name>            define an instance from its configuration file
 ds, destroy <name>           destroy instance
 ex, exec <name> <args>       execute a command in instance
 i , image                    list available images
 ip  <name>                   instance IP-address
 hn, hostname <ip>            instance hostname for given IP
 l , list                     list all instances
 lo, login <name> <args>      login into an instance
 lk, lookup <name>            show network configuration tuple
 m , mount <name>             mount the instance rootfs
 r , remove <name>            delete an instance
 rb, reboot <name>            reboot an instance
 re, redefine <name>          re-define instance after configuration change
 p , path <name>              print path to an instance
 s , shadow <image> <name>    shadow image, and start instance
 sh, shutdown <name>          graceful shutdown instance        
 st, start <name>             start a defined instance
 sy, sync <name> <args>       rsync files to/from instance
 v,  view <name>              view VNC console
 um, umount                   umount instance
 u , undefine <id|fqdn>       undefine instance"


##
# Wraps the `virsh` command
#
function vm() {
  # list VMs by default
  local command=${1:-help}
  # remove first argument if present
  [[ $# -ge 1 ]] && shift
  case "$command" in
  cd)                
    name=${1:?Expecting a virtual machine instance name as argument!}
    cd $(virsh-instance path $name)
    ;;
  clone|cl)                virsh-instance clone $@ ;;
  create|c)                virsh create $@ ;;
  config|co)               
    vm cd $1
    shift
    virsh-config $@ 
    cd - >/dev/null
    ;;
  define|d)
    virsh define $(virsh-instance path $1)/libvirt_instance.xml
    ;;
  destroy|ds)
    virsh destroy $(virsh-instance fqdn $1) | sed '/^$/d'
    ;;
  image|i)                 virsh-instance image ;;
  ip)
    virsh-nat-bridge lookup $1 | cut -d' ' -f2 
    ;;
  list|l)
    virsh list --all | tail -n +3 | sed '/^$/d' | tr -s ' ' | cut -d' ' -f3- 
    ;;
  login|lo|exec|ex)
    vm cd $1
    shift
    ssh-instance $@
    cd - >/dev/null
    ;;
  lookup|lk)               virsh-nat-bridge lookup $@ ;;
  mount|m)                 vm cd $1 ; shift ; sshfs-instance mount $@ ; cd - >/dev/null;;
  hostname|name|hn)
    virsh-nat-bridge list | grep $1 | cut -d, -f2
    ;;
  nat|n)                   virsh-nat-bridge $@ ;;
  path|p)                  virsh-instance path $@ ;;
  reboot|rb)               virsh reboot $(virsh-instance fqdn $1) ;;
  remove|r)                virsh-instance remove $@ ;;
  redefine|re)
    virsh-instance remove $1
    sleep 5 # wait for the shutdown
    virsh define $(virsh-instance path $1)/libvirt_instance.xml | sed '/^$/d'
    virsh start $(virsh-instance fqdn $1)
    ;;
  shutdown|sh)             virsh shutdown $(virsh-instance fqdn $1) ;;
  shadow|s)                virsh-instance shadow $@ ;;
  start|st)                virsh start $(virsh-instance fqdn $1) ;;
  sync|sy)
    vm cd $1
    shift
    rsync-instance $@
    cd - >/dev/null 
    ;;
  view|v)                  virt-viewer $(virsh-instance fqdn $1) & ;;
  umount|um)               vm cd $1 ; sshfs-instance umount ; cd - >/dev/null ;;
  undefine|u)              virsh-instance-undefine $1 ;;
  *)
    echo "$VM_FUNCTION_HELP"
    ;;
  esac
}

