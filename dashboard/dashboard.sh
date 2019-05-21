
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

kubectl delete svc kubernetes-dashboard -n kube-system 
kubectl expose deployment kubernetes-dashboard --type=NodePort --name=kubernetes-dashboard -n kube-system 

echo "Use this Host: "
kubectl get pod -o wide -n kube-system | grep dashboard | awk '{ print $7 }'

echo "Use this Port: "
kubectl describe svc kubernetes-dashboard -n kube-system  | grep NodePort:

kubectl create -f dashboard-adminuser.yaml
kubectl create -f dashboard-clusterrolebinding.yaml

echo "Use this token in the dashboard: "
kubectl -n kube-system describe secret admin-user | grep token:

