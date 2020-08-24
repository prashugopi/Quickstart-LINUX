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

WINIMG=/home/intel/Downloads/Win10_2004_English_x64.iso
VIRTIMG=/home/intel/Downloads/virtio-win-0.1.189.iso
qemu-system-x86_64 -enable-kvm -cpu host -bios /usr/share/qemu/bios.bin -drive file=/home/intel/windows/win10.qcow2,if=virtio -m 6144 \
-M pc \
-vga none \
-display gtk,gl=on \
-device vfio-pci-nohotplug,sysfsdev=$GVTg_DEV_PATH/$GVTg_VGPU_UUID,display=on,x-igd-opregion=on \
-net nic,model=virtio -cdrom ${WINIMG} \
-machine kernel_irqchip=on \
-global PIIX4_PM.disable_s3=1 -global PIIX4_PM.disable_s4=1 \
-drive file=${VIRTIMG},index=3,media=cdrom \
-rtc base=localtime,clock=host -smp 4 \
-usb -device usb-tablet \
-net user,smb=$HOME \
-full-screen
