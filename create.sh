#!/bin/bash

sudo apt update && sudo apt upgrade

sudo apt install qemu-kvm libvirt-bin virtinst cloud-utils -y

wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img

sudo qemu-img info bionic-server-cloudimg-amd64.img
sudo qemu-img resize bionic-server-cloudimg-amd64.img 20G
sudo qemu-img info bionic-server-cloudimg-amd64.img

for i in $(seq 1 10);
do
  sudo qemu-img convert -f qcow2 bionic-server-cloudimg-amd64.img /var/lib/libvirt/images/peer${i}.img

  echo """
  #cloud-config
  password: 1234 
  chpasswd: { expire: False }
  ssh_pwauth: True
  hostname: peer${i}
  """ > cloud-peer${i}.txt
  
  sudo cloud-localds /var/lib/libvirt/images/peer${i}.iso cloud-peer${i}.txt
  
  sudo virt-install --name peer${i} --ram 2048 --vcpus 1 --disk /var/lib/libvirt/images/peer${i}.img,device=disk,bus=virtio --disk /var/lib/libvirt/images/peer${i}.iso,device=cdrom --os-type linux --os-variant ubuntu18.04 --virt-type kvm --graphics none --network network=default,model=virtio --import
done
        
