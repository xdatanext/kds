#!/bin/bash


kubectl create -f csi-pvc.yaml

sleep 30

kubectl get pvc
kubectl get pv

kubectl describe pvc
kubectl describe pv
