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

VN_FUNCTION_HELP="\
virsh-nodeset <command>

Loops over a nodeset of VMs define by the \$NODES environment variable.

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
  rs, restart               restart all VM instances"

##
# Operate on a nodeset of virtual machines
#
function virsh-nodeset() {

  # evaluate and remove command argument
  local command=
  if [ "$#" -ne 0 ]
  then
    command=$1
    shift
  else 
    command=help
  fi

  # if unset or empty
  if [ -z $NODES ]
  then
    echo -e "Error: Please set the environment variable \$NODES!\n"
    command=help
  fi    

  # run command given by the user
  case $command in
    command|cmd|c)
      for node in $(nodeset -e $NODES)
      do
        local fqdn=$(virsh-instance fqdn $node)
        cd $(virsh-instance path $fqdn)
        # replace brackets with node FQDN
        ${@//\{\}/$fqdn}
        cd - >/dev/null
      done
      ;;
    config|co)
      for node in $(nodeset -e $NODES)
      do
        local fqdn=$(virsh-instance fqdn $node)
        cd $(virsh-instance path $fqdn)
        virsh-config -n $fqdn $@
        cd - >/dev/null
      done
      ;;
    execute|exec|ex|e)
      local args=$@
      nodeset-loop -s "cd \$(virsh-instance path {}) ; ssh-instance -r '$args'"
      ;;
    shadow|sh|s)
      img=${1:-centos7}
      nodeset-loop virsh-instance shadow $img {}
      ;;
    start|st)
      nodeset-loop virsh-instance start {}
      ;;
    shutdown|sh)
      nodeset-loop virsh-instance shutdown {}
      ;;
    remove|rm|r)
      nodeset-loop virsh-instance remove {}
      ;;
    redefine|rd)
      for node in $(nodeset -e $NODES)
      do
        local fqdn=$(virsh-instance fqdn $node)
        cd $(virsh-instance path $fqdn)
        virsh shutdown $fqdn
        sleep 2
        virsh undefine $fqdn 
        virsh define libvirt_instance.xml
        virsh start $fqdn
        cd - >/dev/null
      done
      ;;
    restart|rs)
      nodeset-loop virsh-instance shutdown {}
      sleep 2
      nodeset-loop virsh-instance start {}
      ;;
    *)
      echo "$VN_FUNCTION_HELP"
      ;;
  esac
}

alias vn=virsh-nodeset
