## Login as root user
```xml
sudo su -
```

## Install neccessary packages
```xml
apt update -y && apt upgrade -y
apt install coreutils      # Essential utilities like  ls, cp, rm etc..
apt install util-linux     # Essential utilities like  mount, fdisk, and login
apt install net-tools      # Essential utilities like  ifconfig, netstat, route etc..
apt install procps         # Essential utilities like  top, ps, and vmstat, the procps
apt install gawk           # Essential utilities like  gawk
apt install curl wget      # Installing curl and wget package
apt install tar nano       # Installing tar and nano package
apt install net-tools -y
apt install unzip -y
apt install iputils-ping -y
```

## Installing AWS CLI on Ubuntu Machine
```xml
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

# Login to AWS CLI
```xml
aws configure
```
Enter the access key, secret access key, region and output format(json)

## Generate Key-Gen Pair
```xml
ssh-keygen -t rsa
```

## Navigate to /usr/local/bin directory
```xml
/usr/local/bin
```

## Purpose:
If we set the directory to /usr/local/bin, we can access the kops and kubectl anywhere in the linux maxhine.

## Install the Kops (https://github.com/kubernetes/kops/releases)
visit the page and install the latetst version of kops version
```xml
wget https://github.com/kubernetes/kops/releases/download/v1.30.2/kops-linux-amd64
```

## Install Kubectl in ubuntu machine (https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
visit the page and install the latetst version of kubectl version
```xml
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

## Go back to the root directory /any other directory and check the kops and kubectl version
```xml
kubectl version
kops version
```

## Edit .bashrc for environment variables
```xml
nano .bashrc
```

## Assign the values in .bashrc file
```xml
export KOPS_STATE_STORE="s3://practisedomain.cloud"
export ZONES="us-east-1a,us-east-1b,us-east-1c"
export CONTROL_PLANE_SIZE="t3.medium"
export NODE_SIZE="t3.medium"
alias ku='kubectl'
```
## Apply the changes .bashrc
```xml
source .bashrc
```

## Install Kubectl Neat (optional)
kubectl-neat is a useful command-line tool to remove unnecessary clutter and metadata from your Kubernetes manifests, making them more readable and maintainable. It works seamlessly with kubectl to fetch and clean up manifests in one command.

```xml
wget https://github.com/itaysk/kubectl-neat/releases/download/v2.0.4/kubectl-neat_linux_amd64.tar.gz
tar -xvzf kubectl-neat_linux_amd64.tar.gz
mv kubectl-neat /usr/local/bin/
```

# Creating K8S Cluster
## KOPS Create Cluster (1Control plane and 2 Nodes)
```xml
kops create cluster --name=practisedomain.cloud \
--state=s3://practisedomain.cloud \
--zones=us-east-1a,us-east-1b,us-east-1c \
--node-count=2 \
--control-plane-count=1 \
--node-size=$NODE_SIZE \
--control-plane-size=$CONTROL_PLANE_SIZE \
--control-plane-zones=us-east-1a \
--control-plane-volume-size=10 \
--node-volume-size=10 \
--ssh-public-key=~/.ssh/id_rsa.pub \
--dns-zone=practisedomain.cloud \
--yes \
--dry-run --output=yaml                     #(To perform dry run)
```

## KOPS Create Cluster (3 Master nodes and 3 Worker Nodes)
```xml
kops create cluster --name=practisedomain.cloud \
--state=s3://practisedomain.cloud \
--zones=us-east-1a,us-east-1b,us-east-1c \
--node-count=3 \
--control-plane-count=3 \
--node-size=t3.medium \
--control-plane-size=t3.medium \
--control-plane-zones=us-east-1a \
--control-plane-volume-size=10 \
--node-volume-size=10 \
--ssh-public-key=~/.ssh/id_rsa.pub \
--dns-zone=practisedomain.cloud \
--yes \
--dry-run --output=yaml      #(To perform dry run)
```

## Validate K8S Cluster
```xml
kops validate cluster --wait 10m --state="s3://practisedomain.cloud"
```

## Delete K8S Cluster
```xml
kops delete cluster --name practisedomain.cloud --state="s3://practisedomain.cloud" --yes
```

## Resources:
``` xml
https://kops.sigs.k8s.io/cli/kops_create_cluster/
```
