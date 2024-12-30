### AWS EKS Cluster Setup
---

### **EKS Overview**

- **EKS** stands for **Elastic Kubernetes Service**.
- **EKS** is a fully managed Kubernetes service provided by AWS.
- It is an ideal platform to run Kubernetes applications due to its **security**, **reliability**, and **scalability**.
- EKS integrates seamlessly with other AWS services such as **Elastic Load Balancer (ELB)**, **CloudWatch**, **AutoScaling**, **IAM**, and **VPC**.
- With **EKS**, you can run Kubernetes clusters on AWS without the need to install, operate, and maintain your own Kubernetes control plane.
- EKS control plane runs across three **availability zones** to ensure high availability and automatically detects and replaces unhealthy masters.
- AWS fully controls the **control plane**, and the user has no control over it.
- **Worker nodes** need to be created and attached to the control plane.
  
### **Pricing**
- EKS has **two charges**:
  - **Control Plane Charge**: $0.10 per hour.
  - **Worker Node Charge**: Based on **instance type** and the **number of instances**.

---

### **Pre-Requisites**

1. **AWS Account** with admin privileges.
2. A **machine** (EC2 or local) to manage/access the EKS cluster using **Kubectl**.
3. **AWS CLI** access to use the **kubectl** utility.

---

### **Steps to Create an EKS Cluster**

#### **Step 1**: Create VPC using CloudFormation

1. Use the following **S3 URL** to launch the VPC stack:
   - URL: [Amazon EKS VPC Private Subnets CloudFormation](https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml)
   - Stack Name: `EKSVPCCloudFormation`

---

#### **Step 2**: Create IAM Role for EKS Cluster

1. Go to **IAM** in the AWS Console.
2. Create a new **IAM Role**:
   - **Entity Type**: AWS Service.
   - **Use Case**: Select **EKS** -> **EKS Cluster**.
   - **Role Name**: `EKSClusterRole` (you can choose any name).

---

#### **Step 3**: Create EKS Cluster using the VPC and IAM Role

1. In the **EKS Console**, create a new EKS Cluster:
   - Select the created **VPC**.
   - Assign the created **IAM Role** (`EKSClusterRole`).
   - Choose **Cluster Endpoint Access** as both **Public & Private**.

---

#### **Step 4**: Create a RedHat EC2 Instance (K8S_Client_Machine)

1. Launch a **RedHat EC2 instance** that will act as your Kubernetes client.
2. Use **Mobaxterm** or any SSH client to connect to the EC2 instance.

##### **Install Kubectl**

Execute the following commands to install `kubectl`:

```bash
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
$ sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
$ kubectl version --client
```

##### **Install AWS CLI**

To install the AWS CLI on your client machine:

```bash
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
$ sudo yum install unzip
$ unzip awscliv2.zip
$ sudo ./aws/install
```

##### **Configure AWS CLI with Credentials**

Set up AWS CLI with your credentials:

```bash
$ aws configure
# Enter your AWS Access Key and Secret Access Key.
```

> **Note**: You can use the root user's access key and secret key for configuring the AWS CLI.

##### **Check the List of EKS Clusters**

```bash
$ aws eks list-clusters
```

---

#### **Step 5**: Create IAM Role for EKS Worker Nodes

1. Create a new **IAM Role** for EKS Worker Nodes with the following policies:
   - `AmazonEKSWorkerNodePolicy`
   - `AmazonEKS_CNI_Policy`
   - `AmazonEC2ContainerRegistryReadOnly`

---

#### **Step 6**: Create Worker Node Group

1. In the **EKS Console**, go to your created EKS cluster.
2. Select **Compute** → **Node Group**.
3. Choose the previously created **IAM Role** for the worker nodes.
4. Select **Instance Type** as `t2.large`.
5. Set the **Minimum** of 2 and **Maximum** of 5 worker nodes.

---

#### **Step 7**: Verify the Node Group

Once the node group is added, you can check the status of your nodes:

```bash
$ kubectl get nodes
$ kubectl get pods --all-namespaces
```

---

#### **Step 8**: Create and Expose a Pod using NodePort Service

1. Create a **Pod** in your EKS cluster.
2. Expose the Pod using a **NodePort** service.

> **Note**: Make sure to enable **NodePort** in the **Security Group** to access it in your browser.
