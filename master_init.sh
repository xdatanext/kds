#!/bin/bash

echo "master_init " $1

logdir=$1

echo "Disable Firewall"
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

read -p "Press enter to kick off to RESET k8s"
kubeadm reset -f
ipvsadm --clear

POD_NETWORK_CIDR=""
read -p "Press enter to kick off to INIT k8s"

# For simple VM cases of single CPU
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=NumCPU 2>&1 | tee $logdir/kinit.log
#kubeadm init --pod-network-cidr=10.244.0.0/16 2>&1 | tee kinit.log
#kubeadm init 2>&1 | tee kinit.log


echo "Kubelet"
systemctl status kubelet
 
mkdir -p ~/.kube
cp -f /etc/kubernetes/admin.conf ~/.kube/config
chown $(id -u):$(id -g) ~/.kube/config
 
echo "Loading IP Virtual Server modules "
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4

kubectl get all --all-namespaces -n kube-system


echo "Setting up CoreDNS"
kubectl get deployment coredns -n kube-system -o yaml > coredns.yaml
sed -i "s/allowPrivilegeEscalation:.*$/allowPrivilegeEscalation: true/g" coredns.yaml
kubectl replace -f coredns.yaml
rm coredns.yaml


# Weave module here is for reference only. We do not use it anymore. 
# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
echo "Setting up Flannel CNI "
if [ -f kube-flannel.yml ]; then
	rm kube-flannel.yml
fi
# Flannel 
wget --quiet https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml

echo ""
echo ""
echo "Please wait for 1-2 mins to make sure all kube-system containers are in the Running state"

# Sleep for 90 seconds and see that it comes up 
sleep 90

kubectl get all --all-namespaces -n kube-system

# echo "Setting up Kubernetes dashboard"
#kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

echo ""
echo ""
echo "Please run the following on all the Kubernetes worker nodes"
echo "Add --ignore-preflight-errors=all if you see warnings that can be ignored"
echo ""
tail -2 $logdir/kinit.log

