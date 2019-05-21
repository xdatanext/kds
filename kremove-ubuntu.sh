#!/bin/bash


apt remove -y kubelet kubeadm kubectl kubernetes-cni 2>&1 | tee kremove.log
