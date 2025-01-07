# Deploying Kubernetes in On-premises Environment

### Introduction

In this class, we will explore how to deploy a Kubernetes cluster in an on-premises environment, specifically for customers who manage their infrastructure in private data centers using Hyper-V or VMware. We'll use **Rancher Kubernetes Engine (RKE)** to simplify the setup, as **Kubeadm** may not be suitable for production-grade clusters.

### Overview of Tools

- **KOPS**: Works only with AWS, Azure, or GCP. Not suitable for on-premises.
- **Kubeadm**: Basic tool for setting up Kubernetes, but not ideal for production environments.
- **Rancher**: Provides a suite of tools to simplify Kubernetes management, including **RKE** (Rancher Kubernetes Engine) for deploying clusters.
- **K3S**: A lightweight version of Kubernetes for edge locations.
- **Certificates**: We will use **mkcert** to generate certificates using a self-created certificate authority.

### Hardware Setup

- **Local Machine (Windows)**: We'll use a Windows machine (e.g., t2.large) as the management machine.
- **Ubuntu Machines**: Three Ubuntu Linux machines will act as worker nodes for the Kubernetes cluster.

---

### 1. Launching Virtual Machines

1. **Launch AWS Console**: 
   - Launch one Windows machine (Microsoft Windows Server 2019) and three Ubuntu machines.

2. **User Data Script for Ubuntu Machines**:
   When launching the Ubuntu machines, add the following **User Data Script** to automatically install Docker:

   ```bash
   #!/bin/bash
   sudo apt-get update -y && sudo apt-get upgrade -y
   sudo apt-get install -y curl 
   curl https://get.docker.com | bash
   sudo usermod -aG root ubuntu
   sudo usermod -aG docker ubuntu
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   sudo systemctl enable docker
   ```

3. **Launch 3 Linux Machines**:
   After the script runs, all three Ubuntu machines will have Docker installed.

---

### 2. Installing RKE and kubectl on Windows

#### Step 1: Install RKE on Windows

- **Download RKE**: Visit the [Rancher RKE GitHub Release Page](https://github.com/rancher/rke/releases).
  - Right-click on the latest release and navigate to the GitHub page.
  - Download the correct version for Windows.

#### Step 2: Install kubectl on Windows

- **Download kubectl**: Go to the [Kubernetes kubectl installation page](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/) and follow the instructions to install `kubectl` on Windows.

#### Step 3: Install VS Code

- **Install Visual Studio Code (VS Code)** from the [official website](https://code.visualstudio.com/Download).

#### Step 4: Move RKE and kubectl to a Folder

- After downloading both files (RKE and kubectl), create a folder named `tools` in `C://` drive.
- Move both files into the `C://tools` folder.

#### Step 5: Set Environment Variables

- Set environment variables for RKE and kubectl to be accessible from the command line. Open `CMD` and check the version of both tools:

   ```bash
   rke version
   kubectl version --short
   ```

---

### 3. Configuring the Kubernetes Cluster

#### Step 1: Create the Cluster Configuration File

- Run the following command to generate the `cluster.yml` configuration template:

   ```bash
   rke config --name cluster.yml
   ```

#### Step 2: Edit the `cluster.yml` File

- Open the generated `cluster.yml` file using Visual Studio Code.
- Update the file with the required configuration for your Kubernetes cluster.

```yaml
# Path to the SSH private key used for connecting to nodes.
ssh_key_path: C:\tools\keypair.pem

# Set the desired name for the Kubernetes cluster.
cluster_name: rke_cluster  

# Specify the desired version of Kubernetes to use for the cluster.
kubernetes_version: v1.25.6-rancher4-1  

# List of nodes in the Kubernetes cluster.
nodes:
  # First node with public IP and roles defined.
  - address: 165.227.114.63  # Public IP address of the first node.
    user: ubuntu  # SSH user to login to the node.
    role: [controlplane, worker, etcd]  # Node roles: controlplane, worker, etcd.

  # Second node with public IP and roles defined.
  - address: 165.227.116.167  # Public IP address of the second node.
    user: ubuntu  # SSH user to login to the node.
    role: [controlplane, worker, etcd]  # Node roles: controlplane, worker, etcd.

  # Third node with public IP and roles defined.
  - address: 165.227.127.226  # Public IP address of the third node.
    user: ubuntu  # SSH user to login to the node.
    role: [controlplane, worker, etcd]  # Node roles: controlplane, worker, etcd.

# Configuration for etcd service, which is the key-value store for Kubernetes.
services:
  etcd:
    snapshot: true  # Enable snapshots for etcd data.
    creation: 6h  # Snapshot creation interval (6 hours).
    retention: 24h  # Snapshot retention period (24 hours).

# Configuration for the Ingress controller, specifically for external TLS termination with ingress-nginx v0.22+.
ingress:
  provider: nginx  # Specify NGINX as the Ingress controller provider.
  options:
    use-forwarded-headers: "true"  # Allow use of forwarded headers for proper routing and TLS termination.

# Network configuration for the Kubernetes cluster.
network:
  plugin: flannel  # Use Flannel as the CNI plugin for networking.
  options:
    flannel_iface: eth0  # Network interface used by Flannel for overlay networking.
    flannel_backend_type: vxlan  # Specify VXLAN as the backend for Flannel's networking.
    flannel_autoscaler_priority_class_name: system-cluster-critical  # Priority class for Flannel autoscaler.
    flannel_priority_class_name: system-cluster-critical  # Priority class for Flannel pods.
```

---

### 4. Deploy the Cluster

After configuring the `cluster.yml` file:

1. Run the following command to deploy the cluster:

   ```bash
   rke up --config cluster.yml
   ```

2. This will create the Kubernetes cluster using the specified configuration.

---
