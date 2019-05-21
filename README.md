## Installing Kubernetes, Datera CSI using CentOS 7.6.1810 or Ubuntu 18.04 

### CentOS 7.6.1810, Kubernetes 1.14, Datera CSI 1.0.6, Docker 18.06.1
### Ubuntu 18.04.2, Kubernetes 1.14,  Datera CSI 1.0.6, Docker 18.06.1

- Please make sure that you can ssh freely from the master node to the 
  worker nodes. 

  On the master node, 
  ```bash
	% ssh-copy-id root@node1
	% ssh-copy-id root@node2
  ```

- Copy this entire script base into each node above 
  ```bash
	% scp -r kds root@node1:/root
	% scp -r kds root@node2:/root
  ```

- Cluster base config( master, workers) should be defined in 
  ```bash
	% vi k8s-config.json
  ```
- Datera Storage CLuster specific configuration
  ```
	% vi datera-config.json
  ```

- Install Kubernetes on all the nodes
  For this sample we will assume 3 nodes running CentOS 7.6.1810 or Ubuntu 18.04.2 

  Please install:
	- Kubernetes
	- Docker 
	- iscsi-initiator-utils(centos) or open-iscsi (ubuntu)

  Please make sure that you can ssh into all nodes from the master 
  login to the master node and install on all nodes as described in 
  step 1. 
  ```bash
	% ./kds install all
  ```
  If you'd like to install only on one node
  ```bash
	% ./kds install node1
  ```
- Now initialize the kubernetes 
  ```bash
	% ./kds init master
	% ./kds init workers
  ```

  This will:
	- Initialize the Kubernetes Master node 
	- make sure that the docker, kubelet is running
	- on all nodes, swap will be turned off
	- Load the ip kernel modules needed 
	- It will set the allowPrivilegedEscalation true for coredns 
	- It will make sure a CNI module for flannel is loaded 

- Now make sure that the datera-csi is available
  On all the nodes node1, node2, node3
  ```bash
	% ./kds datera get
  ```

- Now make sure that the iSCSI receiver is setup for Datera CSI
  On all the nodes node1, node2, node3:
  ```bash
	% ./kds datera install
  ```
- Let's see how the nodes look in Kubernetes
  ```shell_session
	% kubectl get no

		NAME      STATUS   ROLES    AGE   VERSION
		node1   Ready    master   12h   v1.14.0
		node2   Ready    worker   11h   v1.14.0
		node3   Ready    worker   11h   v1.14.0
  ```
- Now let's go through the steps of Loading the CSI driver
  First step is to make sure that the Datera Cluster is accessible
  ```shell_session
		% export DAT_MGMT='DATERA_MGMT_IP'
		% export DAT_USER='admin'
		% export DAT_PASS='password'
		% export DAT_TENANT='/root'
		% export DAT_API='2.2'
		% export DAT_LDAP=''
		% export DAT_DISABLE_LOGPUSH='True'
   ``` 
   Now we will load the yaml that specifies the Datera CSI only. 
   ```bash
		% kubectl apply -f csi-datera-1.0.6.yaml
   ```
   Please refer to the datera-plugin.sh for the steps above:

   Note: These (DAT_MGMT, DAT_USER, DAT_PASS, DAT_TENANT, DAT_API, DAT_LDAP, DAT_DISABLE_LOGPUSH)
   can also be set inside the csi-datera-1.0.6.yaml.
   Default policies you need for Datera Platform can also be specified here. 

   Datera Specific ones are:
		replica_count
		placement_mode
		ip_pool
		template
		read_iops_max
		write_iops_max
		total_iops_max
		iops_per_gb
		fs_type
		fs_args

- Now we will have kubernetes create a Volume on the Datera and ensure that 
  it is seen in Kubernetes. For this example, we will call it csi-pvc
  ```bash
	% kubectl apply -f csi-pvc.yaml
  ```
  This will create a Volume of 10G. We can make sure that the Volume is 
  visible in Kubernetes 
  ```bash
	% kubectl get pvc
  ```

NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
csi-pvc   Bound    pvc-1ce66a63-5021-11e9-a32d-0cc47ac7f22e   10Gi       RWO            dat-block-storage   8m


- Now we want to make sure that the Application can use this Volume
  ```bash
	% kubectl apply -f csi-app.yaml
  ```
  if you look at the file csi-app.yaml , it is a simple container that simply uses a mountpoint /data 
  for the csi-pvc and sleeps. 
  The Volume reference looks like : 
  ```yaml
	volumes:
		- name: my-app-volume
	      persistentVolumeClaim:
	          claimName: csi-pvc
  ```

   Once the application is created and the Pod created
   ```shell_session
	% kubectl get po
	NAME         READY   STATUS    RESTARTS   AGE
	my-csi-app   1/1     Running   0          12m
   ```

- Now if you'd like to run fio, vdbench for performance numbers 
  ```bash
	% ./kds diobench
  ```
  This will fetch the diobench yamls from github and submit it as a job. 
  Please refer to the diobench github for FIO/VDBENCH selection


