# K8S INGRESS CONTROLLER
Before Start works on K8S Ingress Controller create a certificates for TLS-SSL Certificates.

# Generate SSL Certificate
Copy id_rsa.pub to you local and saved as PPK file. use this ppk file to login to master node via generated SSH (id_rsa.pub)

# Certbot SSL Certificate Setup with DNS Challenge (Route53)
# 1. Installing Certbot
Install Certbot using Snap
Certbot is a tool that automates the process of obtaining and renewing SSL certificates from Let's Encrypt. <br>To install Certbot on your server:
```xml
sudo snap install --classic certbot
```
### Create a Symlink for Easier Access
<br>After installation, create a symbolic link to /usr/local/bin/ for easy access to Certbot commands:
```xml
cd /snap/bin
cp certbot /usr/local/bin/
```
<br>This ensures you can run certbot from any directory.

### Verify the Installation
<br>To confirm that Certbot was installed successfully, run:
```xml
certbot -h
```
<br>This will display the Certbot help menu with available commands and options.

# 2. Requesting an SSL Certificate -Command to Request the Certificate
<br>Run the following command to request an SSL certificate for your wildcard domain *.practisedomain.cloud using DNS-01 challenge:
```xml
certbot certonly --manual --preferred-challenges dns --key-type rsa --email vamsikrishna2049@gmail.com \
--server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d "*.practisedomain.cloud"
```
<br>Explanation of Flags:
<br>--manual: Use manual mode to handle DNS challenges.
<br>--preferred-challenges dns: Specifies the DNS-01 challenge type.
<br>--key-type rsa: Use RSA key algorithm.
<br>--email vamsikrishna2049@gmailcom: Contact email for the certificate.
<br>--agree-tos: Agree to Let's Encrypt's terms of service.
<br>-d "*.practisedomain.cloud": Request a wildcard certificate for the domain practisedomain.cloud.

#### Approve the Terms of Service
Once the command is executed, Certbot will ask for confirmation of the Terms of Service. 
#### Type Yes to proceed.

# 3. DNS Validation Setup in AWS Route53
Add DNS Record in Route53.
<br>Certbot will prompt you to create a TXT record in your DNS provider (Route53 in this case) to prove domain ownership.

### Log in to your AWS Route53 console.
Select the hosted zone for your domain (practisedomain.cloud).
<br>Add a new DNS record:
Record Name: 
```xml
_acme-challenge
```
Record Type: 
```xml
TXT
```
Record Value: 
```xml
9Y2EdG0nT0QNaJtGtIN-Euu1zc9ZVuCz2mhAe_SO3os
```
This value will be provided by Certbot after initiating the process.

Save the record.

### DNS Propagation (Wait for 2-3 min)
It may take several minutes for the DNS record to propagate. Certbot will attempt to verify the DNS record before issuing the certificate.

# 4. Finalizing and Locating SSL Certificate Files
Once the validation is complete and the certificate is issued, you can find the certificate and private key in the following directory:

### Certificate (tls.crt):
``` xml
/etc/letsencrypt/live/practisedomain.cloud/fullchain.pem
```
### Private Key (tls.key):
``` xml
/etc/letsencrypt/live/practisedomain.cloud/privkey.pem
```
### Certificate Expiry Date
Your SSL certificate will be valid for 90 days. The expiration date can be found in the following location:
<br>Expiration Date: 2025-03-01

Make sure to renew your certificate before this date using Certbot’s automated renewal process.
<br>Login to K8S Master Node and install
Certbot is required
