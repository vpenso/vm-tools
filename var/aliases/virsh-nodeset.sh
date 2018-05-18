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
vn <command>

command:
  c,  command <args>        execute a command in the path of each VM instance
  co, config <args>         write a libvirt configuration file (cf. virsh-config)
  ex, execute <args>        execute a command in each VM instance 
  st, start                 start all VM instances
  sh, shutdown              shutdown all VM instances
  sh, shadow <image>        start VM instances using a template
  rm, remove                remove all VM instances
  rs, restart               restart all VM instances"

##
# Operate on a nodeset of virtual machines
#
function virsh-nodeset() {
  local command=$1
  case $command in
    "command"|"cmd"|"c")
      shift
      for node in $(nodeset -e $NODES)
      do
        echo $node
        cd $(virsh-instance path $node)
        $@
        cd - >/dev/null
      done
      ;;
    "config"|"co")
      shift
      for node in $(nodeset -e $NODES)
      do
        cd $(virsh-instance path $node)
        virsh-config $@
        cd - >/dev/null
      done
      ;;
    "execute"|"exec"|"ex"|"e")
      shift
      local args=$@
      nodeset-loop -s "cd \$(virsh-instance path {}) ; ssh-instance -r '$args'"
      ;;
    "shadow"|"sh"|"s")
      img=${2:-centos7}
      nodeset-loop virsh-instance shadow $img {}
      ;;
    "start"|"st")
      nodeset-loop virsh-instance start {}
      ;;
    "shutdown"|"sh")
      nodeset-loop virsh-instance shutdown {}
      ;;
    "remove"|"rm"|"r")
      nodeset-loop virsh-instance remove {}
      ;;
    "restart"|"rs")
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
