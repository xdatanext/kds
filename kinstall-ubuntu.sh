#!/bin/bash

# This will work with Ubuntu 16+ only

echo "kinstall-ubuntu"

# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
apt-get update && apt-get install -y docker-ce=18.06.2~ce~3-0~ubuntu

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add 

if [ -f /etc/apt/sources.list.d/kubernetes.list ]; then
	rm /etc/apt/sources.list.d/kubernetes.list 
fi

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list 

apt-get update
apt-get install -y kubelet kubeadm kubectl kubernetes-cni open-iscsi ipvsadm 2>&1 | tee kinstall.log


# needed for ipvs
echo -e "net.bridge.bridge-nf-call-ip6tables = 1 \nnet.bridge.bridge-nf-call-iptables = 1" > /etc/sysctl.d/k8s.conf


