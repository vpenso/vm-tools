# connect to the local libvirtd instance (run as root)
export LIBVIRT_DEFAULT_URI=qemu:///system

# path to virtual machine images
if [ -z "${VM_IMAGE_PATH+1}" ]; then
    export VM_IMAGE_PATH=$VM_FUNCTIONS/vm/images
fi

# path to virtual machine instances
if [ -z "${VM_INSTANCE_PATH+1}" ]; then
    export VM_INSTANCE_PATH=$VM_FUNCTIONS/vm/instances
fi

# default DNS domain
export VM_DOMAIN=devops.test

# create directories if missing
test -d $VM_IMAGE_PATH || mkdir -p $VM_IMAGE_PATH
test -d $VM_INSTANCE_PATH || mkdir -p $VM_INSTANCE_PATH

