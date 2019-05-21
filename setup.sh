#!/bin/bash

OST=`grep "ID=" /etc/os-release | grep -v VERSION | awk -F= '{ print $2 }' | sed 's/\"//g'`
if [ $OST = "ubuntu" ]; then
	apt update
	apt install -y vim jq wget 
fi

if [ $OST = "centos" ]; then
	yum update
	yum install -y epel-release deltarpm
	yum install -y yum-utils
	yum install -y vim jq wget
fi
