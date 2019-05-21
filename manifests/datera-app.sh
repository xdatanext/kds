#!/bin/bash


kubectl create -f csi-app.yaml

sleep 30 

kubectl get po

kubectl describe pod


