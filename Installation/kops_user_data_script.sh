#!/bin/bash

# Check if required commands are available
command -v curl >/dev/null 2>&1 || { echo "curl is required but not installed. Exiting."; exit 1; }
command -v wget >/dev/null 2>&1 || { echo "wget is required but not installed. Exiting."; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo "unzip is required but not installed. Exiting."; exit 1; }

# Update the system and install required packages
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y curl wget tar unzip

# Amazon CLI install
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws/

# Check AWS CLI installation
if ! command -v aws &>/dev/null; then
  echo "AWS CLI installation failed"
  exit 1
fi

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Install KOPS
wget https://github.com/kubernetes/kops/releases/download/v1.30.2/kops-linux-amd64
chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

# Generate SSH Key Pair for access to EC2 instances
ssh-keygen -t rsa -b 4096 -f ~/.ssh/kops_key -N ""
chmod 600 ~/.ssh/kops_key

# Set environment variables
export KOPS_STATE_STORE="s3://practisedomain.cloud"
export ZONES="us-east-1a,us-east-1b,us-east-1c"
export CONTROL_PLANE_SIZE="t3.medium"
export NODE_SIZE="t3.medium"

# Add aliases for kubectl
echo "alias ku='kubectl'" >> ~/.bashrc
source ~/.bashrc

# Create Kubernetes Cluster using KOPS
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
--ssh-public-key=~/.ssh/kops_key.pub \
--dns-zone=practisedomain.cloud

# Validate the cluster (wait for up to 10 minutes)
echo "Validating the cluster. This may take up to 10 minutes..."
kops validate cluster --wait 10m --state="s3://practisedomain.cloud"

# Check if cluster validation was successful
if [ $? -eq 0 ]; then
  echo "Cluster validation successful!"
else
  echo "Cluster validation failed!"
  exit 1
fi

echo "Installation completed successfully!"
