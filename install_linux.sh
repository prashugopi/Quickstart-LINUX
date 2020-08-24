#!/bin/bash

GVTg_DEV_PATH="/sys/bus/pci/devices/0000:00:02.0"
GVTg_VGPU_UUID="edca9983-77ff-43ab-ad52-cf13921103ec"
function setup_vgpu(){
        res=0
        if [ ! -d $GVTg_DEV_PATH/$GVTg_VGPU_UUID ]; then
                echo "Creating VGPU..."
                sudo sh -c "echo $GVTg_VGPU_UUID > $GVTg_DEV_PATH/mdev_supported_types/i915-GVTg_V5_4/create"
                res=$?
        fi
        return $res
}

function check_nested_vt(){
        nested=$(cat /sys/module/kvm_intel/parameters/nested)
        if [[ $nested != 1 && $nested != 'Y' ]]; then
                echo "E: Nested VT is not enabled!"
                exit -1
        fi
}

check_nested_vt
setup_vgpu

LOCALDIR=$(pwd)
LINIMG=/home/intel/Downloads/ubuntu-20.04.1-desktop-amd64.iso

qemu-system-x86_64 -enable-kvm -cpu host \
-bios /usr/share/qemu/bios.bin \
-drive file=${LOCALDIR}/linux.qcow2 \
-m 4g \
-M pc \
-vga qxl \
-display gtk,gl=on \
-net nic,model=e1000 \
-cdrom ${LINIMG} \
-net user \
-machine kernel_irqchip=on \
-global PIIX4_PM.disable_s3=1 -global PIIX4_PM.disable_s4=1 \
-smp 4 \
-usb -device usb-tablet \
#-rtc base=localtime,clock=host 
#-device vfio-pci-nohotplug,sysfsdev=$GVTg_DEV_PATH/$GVTg_VGPU_UUID,display=off,x-igd-opregion=on \
#-net user,smb=$HOME
#-net nic,model=virtio -cdrom ${LINIMG} \
