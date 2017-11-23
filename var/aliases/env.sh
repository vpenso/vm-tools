
export LIBVIRT_DEFAULT_URI=qemu:///system
# path to virtual machine images
export VM_IMAGE_PATH=$VM_FUNCTIONS/vm/images
# path to virtual machine instances
export VM_INSTANCE_PATH=$VM_FUNCTIONS/vm/instances
# default DNS domain
export VM_DOMAIN=devops.test

# create directories if missing
test -d $VM_IMAGE_PATH || mkdir -p $VM_IMAGE_PATH
test -d $VM_INSTANCE_PATH || mkdir -p $VM_INSTANCE_PATH

