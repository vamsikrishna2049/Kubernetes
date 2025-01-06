Remove the AWS CLI installation

---

The AWS CLI v2 typically installs itself under /usr/local/bin/aws and places its files in /usr/local/aws-cli/. You can remove these files with the following commands:

```bash
sudo rm -rf /usr/local/aws-cli
sudo rm -f /usr/local/bin/aws
```
Remove the configuration and credential files (optional):
If you no longer need the AWS CLI configuration files, you can remove the .aws directory from your home directory (this will delete the AWS configuration, including credentials):
```bash
rm -rf ~/.aws
```

Verify the verion
```bash
aws --version
```
