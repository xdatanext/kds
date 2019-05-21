#!/bin/bash

echo "worker_init" $1
logdir=$1

# disable Firewall for Lab systems
echo "Disable Firewall "
systemctl disable firewalld
systemctl stop firewalld
systemctl status firewalld

echo "Enable Docker "
sysctl --system
systemctl enable docker
systemctl start docker

echo "Enable kubelet"
systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet

echo "Docker ..."
systemctl status docker
echo "Kubelet"
systemctl status kubelet

echo "Loading IP Virtual Server modules "
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4


# Do the iSCSI portion only. 
OST=`grep "ID=" /etc/os-release | grep -v VERSION | awk -F= '{ print $2 }' | sed 's/\"//g'`
echo $OST
if [ $OST == "ubuntu" ]; then
	$logdir/iscsi-ubuntu.sh
fi

if [ $OST == "centos" ]; then
	$logdir/iscsi-centos.sh
fi

echo "Making sure swap is turned off "
swapoff -a

# kubeadm join needs it
read -p "Press enter to kick off to RESET k8s"
kubeadm reset -f

echo "Please enter the command from the master for kubeadm join ..... "


