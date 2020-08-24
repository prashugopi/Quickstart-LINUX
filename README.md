# Quickstart-LINUX

## Install 5.4/idv_dev Kernel

## Download Ubuntu 20.04.1 LTS Desktop image
https://releases.ubuntu.com/20.04/

## Create a disk image file
```
qemu-img create -f qcow2 linux.qcow2 20G
```

## Run installation and start scripts
Edit LINIMG variable in install_linux.sh to path to 20.04 Desktop Image
```
sudo ./install_linux

sudo ./start_linux
```
