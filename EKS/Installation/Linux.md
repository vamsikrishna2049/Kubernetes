```bash
# Get the machine architecture
ARCH=$(uname -m)

#Find the linux Type and Perform Updates install Packages
if grep -i "ubuntu" /etc/os-release > /dev/null; then
    # If it's Ubuntu
    echo "Detected Ubuntu"
    sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get autoremove -y
    # AWS Configure
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

# Architecture check and kubectl download
if [[ "$ARCH" == "x86_64" ]]; then

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.2/2024-11-15/bin/linux/amd64/kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.2/2024-11-15/bin/linux/amd64/kubectl.sha256
sha256sum -c kubectl.sha256
# Make kubectl executable
chmod +x ./kubectl
#Copy the binary to a folder in your PATH. If you have already installed a version of kubectl, then we recommend creating a $HOME/bin/kubectl and ensuring that $HOME/bin comes first in your $PATH.
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH


#Add the $HOME/bin path to your shell initialization file so that it is configured when you open a shell.
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

if [ $? -ne 0 ]; then
    echo "Failed to download kubectl."
    exit 1
fi

# Check if .bashrc exists and update it
if [ -f "$HOME/.bashrc" ]; then
    grep -qxF 'export PATH=$HOME/bin:$PATH' "$HOME/.bashrc" || echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.bashrc"
fi

# Check if .bash_profile exists and update it
if [ -f "$HOME/.bash_profile" ]; then
    grep -qxF 'export PATH=$HOME/bin:$PATH' "$HOME/.bash_profile" || echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.bash_profile"
fi

# For systems using .bash_profile, also ensure .bashrc is sourced in .bash_profile
if ! grep -q 'source ~/.bashrc' "$HOME/.bash_profile"; then
    echo 'if [ -f "$HOME/.bashrc" ]; then' >> "$HOME/.bash_profile"
    echo '    source ~/.bashrc' >> "$HOME/.bash_profile"
    echo 'fi' >> "$HOME/.bash_profile"
fi


#Refreshing the shell environment
source ~/.bashrc

# Verify the kubectl installation
echo "Verifying kubectl installation..."
kubectl version --short --client

echo "kubectl installation completed successfully!"

curl -sLO https://github.com/eksctl-io/eksctl/releases/download/v0.199.0/eksctl_Linux_amd64.tar.gz
# Extract and move eksctl binary to /usr/local/bin
tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp && rm eksctl_Linux_amd64.tar.gz
# move the eksctl to /usr/local/bin - Setting environment variable
sudo mv /tmp/eksctl /usr/local/bin


# Verify eksctl installation
echo "Verifying eksctl installation..."
eksctl version

echo "eksctl installation completed successfully!"



elif [[ "$ARCH" == "aarch64" ]]; then
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.2/2024-11-15/bin/linux/amd64/kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.2/2024-11-15/bin/linux/amd64/kubectl.sha256
sha256sum -c kubectl.sha256
# Make kubectl executable
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

if [ $? -ne 0 ]; then
    echo "Failed to download kubectl."
    exit 1
fi

#Refreshing the shell environment
source ~/.bashrc

# Verify the kubectl installation
echo "Verifying kubectl installation..."
kubectl version --short --client

echo "kubectl installation completed successfully!"

curl -sLO https://github.com/eksctl-io/eksctl/releases/download/v0.199.0/eksctl_Linux_amd64.tar.gz
# Extract and move eksctl binary to /usr/local/bin
tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp && rm eksctl_Linux_amd64.tar.gz
# move the eksctl to /usr/local/bin - Setting environment variable
sudo mv /tmp/eksctl /usr/local/bin


# Verify eksctl installation
echo "Verifying eksctl installation..."
eksctl version

echo "eksctl installation completed successfully!"
-----------------------------------------------------------------
elif grep -i "centos" /etc/os-release > /dev/null || grep -i "redhat" /etc/os-release > /dev/null; then
    # If it's Red Hat or CentOS
    echo "Detected Red Hat or CentOS"
    sudo yum update -y && sudo yum upgrade -y && sudo yum autoremove -y

    # AWS Configure
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

# Architecture check and kubectl download
if [[ "$ARCH" == "x86_64" ]]; then

curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.2/2024-11-15/bin/linux/amd64/kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.2/2024-11-15/bin/linux/amd64/kubectl.sha256
sha256sum -c kubectl.sha256
# Make kubectl executable
chmod +x ./kubectl
#Copy the binary to a folder in your PATH. If you have already installed a version of kubectl, then we recommend creating a $HOME/bin/kubectl and ensuring that $HOME/bin comes first in your $PATH.
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH


#Add the $HOME/bin path to your shell initialization file so that it is configured when you open a shell.
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

if [ $? -ne 0 ]; then
    echo "Failed to download kubectl."
    exit 1
fi

# Check if .bashrc exists and update it
if [ -f "$HOME/.bashrc" ]; then
    grep -qxF 'export PATH=$HOME/bin:$PATH' "$HOME/.bashrc" || echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.bashrc"
fi

# Check if .bash_profile exists and update it
if [ -f "$HOME/.bash_profile" ]; then
    grep -qxF 'export PATH=$HOME/bin:$PATH' "$HOME/.bash_profile" || echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.bash_profile"
fi

# For systems using .bash_profile, also ensure .bashrc is sourced in .bash_profile
if ! grep -q 'source ~/.bashrc' "$HOME/.bash_profile"; then
    echo 'if [ -f "$HOME/.bashrc" ]; then' >> "$HOME/.bash_profile"
    echo '    source ~/.bashrc' >> "$HOME/.bash_profile"
    echo 'fi' >> "$HOME/.bash_profile"
fi


#Refreshing the shell environment
source ~/.bashrc

# Verify the kubectl installation
echo "Verifying kubectl installation..."
kubectl version --short --client

echo "kubectl installation completed successfully!"

curl -sLO https://github.com/eksctl-io/eksctl/releases/download/v0.199.0/eksctl_Linux_amd64.tar.gz
# Extract and move eksctl binary to /usr/local/bin
tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp && rm eksctl_Linux_amd64.tar.gz
# move the eksctl to /usr/local/bin - Setting environment variable
sudo mv /tmp/eksctl /usr/local/bin


# Verify eksctl installation
echo "Verifying eksctl installation..."
eksctl version

echo "eksctl installation completed successfully!"



elif [[ "$ARCH" == "aarch64" ]]; then
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.2/2024-11-15/bin/linux/amd64/kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.2/2024-11-15/bin/linux/amd64/kubectl.sha256
sha256sum -c kubectl.sha256
# Make kubectl executable
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

if [ $? -ne 0 ]; then
    echo "Failed to download kubectl."
    exit 1
fi

#Refreshing the shell environment
source ~/.bashrc

# Verify the kubectl installation
echo "Verifying kubectl installation..."
kubectl version --short --client

echo "kubectl installation completed successfully!"

curl -sLO https://github.com/eksctl-io/eksctl/releases/download/v0.199.0/eksctl_Linux_amd64.tar.gz
# Extract and move eksctl binary to /usr/local/bin
tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp && rm eksctl_Linux_amd64.tar.gz
# move the eksctl to /usr/local/bin - Setting environment variable
sudo mv /tmp/eksctl /usr/local/bin


# Verify eksctl installation
echo "Verifying eksctl installation..."
eksctl version

echo "eksctl installation completed successfully!"

else
    echo "Unknown Linux distribution"
    exit 1
fi
```
