To upgrade a kubernetes cluster, there are two main concepts involved.

## 1. Node Drain
Node draining is the method of safely removing all pods from a node, getting it ready for maintenance tasks like upgrades or shutdowns.
When you initiate a node drain, Kubernetes automatically evicts and reschedules the regular application pods running on that node to other available nodes in the cluster.
### Note:
When you perform a node drain operation in Kubernetes, the control plane pods (also known as system pods) running on the node are not evicted. This is intentional behavior to ensure the stability and availability of the Kubernetes control plane components.

## 2. Node Uncordon
Uncordon is the process of marking a node as ready to schedule pods again after it has been previously drained.

You can also cordon a node. This means making the node unschedulable, but without evicting the existing pods. However, during an upgrade process, we choose to drain the node instead of just cordoning it, because we also want to evict the pods.

## Cluster Upgrade Using Kubeadm
To upgrade clusters using kubeadm, we will follow the below steps:
**1. Update the Kubeadm Tool:** We begin by updating the kubeadm tool to the latest version. This ensures compatibility with newer cluster versions.
**2. Upgrade the Cluster:** After updating kubeadm, we upgrade the cluster to the desired version.
**a. Upgrade Order:** We execute the upgrades in the following sequence:Control Plane: Upgrade the control plane components first.
**b. Worker Nodes:** Follow with the worker nodes.
**c. Components to Upgrade: Control Plane Node:** Upgrade the control plane components, Kubelet, and kubectl.
**d. Worker Nodes:** Upgrade the Kubelet on each worker node.
