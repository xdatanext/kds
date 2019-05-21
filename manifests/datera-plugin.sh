#!/bin/bash

# Please update these in the csi-datera-1.0.6.yaml 

#export DAT_MGMT='172.19.2.81'
#export DAT_USER='admin'
#export DAT_PASS='password'
#export DAT_TENANT='/root'
#export DAT_API='2.2'
#export DAT_LDAP=''
#export DAT_DISABLE_LOGPUSH='True'

kubectl create -f csi-datera-1.0.6.yaml

echo ""
echo "Waiting for 1 min to let CSI Plugin installation to complete.."
sleep 60 

kubectl get storageclasses

kubectl get po -n kube-system | grep csi

