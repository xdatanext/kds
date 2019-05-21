#!/bin/bash

yum remove -y kubelet kubeadm kubectl \
		docker-ce docker-ce-cli docker-client docker-client-latest docker-common \
                docker-latest docker-latest-logrotate docker-logrotate \
                docker-selinux docker-engine-selinux docker-engine \
                iscsi-initiator-utils kubernetes-cni --disableexcludes=kubernetes \
		--skip-broken 2>&1 | tee kremove.log

