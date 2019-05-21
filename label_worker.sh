#!/bin/bash


if [ -z $1 ]; then
    echo $0 " <nodename>"
    exit
fi

echo "Labelling node $1 as a worker"
kubectl label node $1 node-role.kubernetes.io/worker=worker
kubectl get no $1
