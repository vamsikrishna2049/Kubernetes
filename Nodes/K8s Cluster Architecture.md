The first thing to understand about Kubernetes is that it's a distributed system. This means it consists of multiple components spread across different servers on a network. These servers can either be virtual machines or physical (bare metal) servers, collectively forming what we call a Kubernetes cluster.

The following Kubernetes architecture diagram illustrates all the components of a Kubernetes cluster and how external systems interact with it.

![Alt Text](Nodes/images/02-k8s-architecture.gif)


A Kubernetes cluster consists of both control plane nodes and worker nodes.

## Control Plane
The control plane is responsible for orchestrating containers and maintaining the cluster's desired state. Its components include:

1. kube-apiserver: This is the main interface for the cluster. It receives commands and requests from users (kubectl) and other sources (third party apps), ensuring they are valid and processing them accordingly.
2. etcd: This is a key-value store that keeps all the configuration data and state information for the cluster. It acts like a database for Kubernetes.
3. kube-scheduler: This component decides which worker node will run a new pod (a group of containers). It looks at resource availability on nodes and other factors to schedule the pod.
4. kube-controller-manager: This manages various controllers that handle routine tasks in the cluster, such as ensuring that the desired number of pods are running.
5. cloud-controller-manager: This optional component connects Kubernetes with cloud services. It handles tasks specific to the cloud provider, like managing load balancers or storage.
A cluster may have one or more control plane nodes.

## Worker Node
Worker nodes are responsible for running containerized applications. Each worker node includes the following components:

1. kubelet: This is an agent on each worker node that communicates with the control plane. It ensures that containers are running as they should based on instructions from the control plane.
2. kube-proxy: This manages network rules on each node, allowing communication between pods and external services. It helps route traffic to the correct pods.
3. Container runtime: This is the component responsible for running the containers themselves. Examples include CRIO, Docker and containerd.

### Important Note: These components run on the control plane node as well.
## Add-on Components
Additionally, there are add-on components we include in the cluster to extend its functionality and make the cluster fully functional for application deployments.

Here are some common add-ons commonly used in Kubernetes Clusters
1. Web UI: A graphical interface that allows users to manage and monitor their Kubernetes resources easily.
2. CoreDNS: A service that provides DNS (Domain Name System) capabilities within the cluster, allowing pods to resolve each other's names to IP addresses.
3. Metrics Server: This collects resource usage data (like CPU and memory) from pods, helping with monitoring and scaling decisions.
4. CNI Plugins (Container Network Interface): These provide networking capabilities for pods, allowing them to communicate with each other and with external networks.

### Important Note: If you're new to Kubernetes, diving deep into each component may feel complex and overwhelming.
