etcd is an integral part of the cluster. All the cluster objects and their state is stored in etcd.

Here are few things you should know about etcd.
1. It is a consistent, distributed, and secure key-value store.
2. It uses ![raft protocol](https://raft.github.io/).
3. It stores Kubernetes cluster configurations, all API objects, object states, and service discovery details.
4. etcd stores all objects under the /registry directory key in key-value format. For example, information on a pod named Nginx in the default namespace can be found under /registry/pods/default/nginx

![ETCD1](https://github.com/vamsikrishna2049/Kubernetes/blob/970864ed72f406eeaa6ff9e9a646f9c2d6db70a9/Nodes/images/3.ETCD%20and%20ETCDL/etcd%20and%20etcdl%20-1.png)

## etcd Backup & Restore Using etcdctl

Here is what you should know about etcd backup.
1. etcd has a built-in snapshot mechanism.
2. etcdctl is the command line utility that interacts with etcd for snapshots.
![ETCD2](https://github.com/vamsikrishna2049/Kubernetes/blob/970864ed72f406eeaa6ff9e9a646f9c2d6db70a9/Nodes/images/3.ETCD%20and%20ETCDL/etcd%20and%20etcdl%20-2.png)

When it comes to real-world projects, tools like Velero are used for cluster backup, recovery, and disaster recovery purposes.

## Install etcdctl
Login to the control plane node and install etcdctl using the following command.

```bash
sudo apt install etcd-client
```

Validate the installation by checking the etcdctl version.

```bash
etcdctl version
etcdctl version: 3.3.25
API version: 2
```

## Note:
In the CKA exam terminal, etcdctl is installed by default. You don't have to install it.
