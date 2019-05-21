#!/bin/bash

echo "kinstall-centos" $1
script_dir=$1

yum update -y
yum install -y epel-release
yum install -y jq yum-utils lvm2 device-mapper-persistent-data vim device-mapper-multipath.x86_64 ipvsadm

echo "Making sure docker repo is there "
#yum-config-manager --add-repo $script_dir/docker-ce.repo
yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
yum makecache fast

#yum-config-manager --enable $script_dir/docker-ce-edge
#yum-config-manager --enable $script_dir/docker-ce-test
echo -e "[kubernetes] \nname=Kubernetes \nbaseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64 \nenabled=1 \ngpgcheck=0 \nrepo_gpgcheck=1 \ngpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg \nhttps://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" > /etc/yum.repos.d/kubernetes.repo
yum makecache fast

yum install -y kubelet-1.14.2-0 kubeadm-1.14.2-0 kubectl-1.14.2-0 \
		docker-ce-18.06.1.ce iscsi-initiator-utils kubernetes-cni-0.7.5 --disableexcludes=kubernetes \
		--skip-broken 2>&1 | tee kinstall.log
 
#yum install -y kubelet kubeadm kubectl docker-ce-18.06.2.ce iscsi-initiator-utils --disableexcludes=kubernetes \
#                --skip-broken 2>&1 | tee kinstall.log

# needed for ipvs
echo -e "net.bridge.bridge-nf-call-ip6tables = 1 \nnet.bridge.bridge-nf-call-iptables = 1" > /etc/sysctl.d/k8s.conf


