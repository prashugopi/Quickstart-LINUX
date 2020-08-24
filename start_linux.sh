#!/bin/bash
LOCALDIR=$(pwd)

qemu-system-x86_64 -enable-kvm -cpu host \
-bios /usr/share/qemu/bios.bin \
-drive file=${LOCALDIR}/linux.qcow2 \
-m 4g \
-M pc \
-vga qxl \
-display gtk,gl=on \
-net nic,model=e1000 \
-net user \
-machine kernel_irqchip=on \
-global PIIX4_PM.disable_s3=1 -global PIIX4_PM.disable_s4=1 \
-smp 4 \
-usb -device usb-tablet \
