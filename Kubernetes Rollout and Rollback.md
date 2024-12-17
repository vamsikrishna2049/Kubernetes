# Kubernetes Rollout and Rollback Documentation

## 1. **Overview**
Kubernetes provides a powerful mechanism to manage application updates using **rollouts** and **rollbacks**. Rollouts enable you to update your application gradually, ensuring zero-downtime deployments. Rollbacks allow you to revert to a previous stable state if issues arise during a rollout.

## 2. **Pre-requisites**
Before using Kubernetes rollout and rollback features, ensure that the following prerequisites are met:

### 2.1 **Kubernetes Cluster**
- You must have a **running Kubernetes cluster** (on-premise or cloud-based) where your application will be deployed.
  - You can verify your cluster status using:
    ```bash
    kubectl get nodes
    ```

### 2.2 **kubectl**
- You must have **kubectl** installed on your local machine, and it should be configured to communicate with your Kubernetes cluster.
  - To check your kubectl version:
    ```bash
    kubectl version --client
    ```

### 2.3 **Deployment Configuration**
- A **Kubernetes Deployment** should already be created and deployed in the cluster. This deployment must be updated (either via `kubectl set image` or other means) to use **RollingUpdate** strategy for smooth rollouts.
  - Example Deployment YAML for a typical application (nginx):
    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
    spec:
      replicas: 3
      selector:
        matchLabels:
          app: nginx
      template:
        metadata:
          labels:
            app: nginx
        spec:
          containers:
          - name: nginx
            image: nginx:perl
    ```
---

## 3. **Rollout in Kubernetes**
A **rollout** refers to updating your application (e.g., container image update) in a controlled, gradual manner without downtime.

### 3.1 **Trigger a Rollout**
To update a deployment (e.g., updating the nginx image version), use the `kubectl set image` command.

- Example: Updating the `nginx` container image:
  ```bash
  kubectl set image deployment/nginx-deployment nginx=nginx:stable-bookworm-perl
  ```

This triggers a **rolling update**, where Kubernetes gradually replaces old pods with new ones.

### 3.2 **Monitor Rollout Status**
To check the status of the rollout, run:
```bash
kubectl rollout status <deployment/nginx-deployment>
```
This will show if the rollout was successful or if there were issues.

### 3.3 **Pause a Rollout** (Optional)
If you need to temporarily halt a rollout (e.g., for debugging or manual intervention), use:
```bash
kubectl rollout pause <deployment/nginx-deployment>
```

### 3.4 **Resume a Paused Rollout** (Optional)
If the rollout was paused, you can resume it:
```bash
kubectl rollout resume <deployment/nginx-deployment>
```

### 3.5 **Check Rollout History**
Kubernetes keeps track of previous rollout revisions. You can view the history using:
```bash
kubectl rollout history deployment/nginx-deployment
```
This command displays the deployment revision history along with change causes (if recorded).

### 3.6 **Undo Rollback**
To undo the deployment and roll it back to the previous revision, use the kubectl rollout undo command:
```bash
kubectl rollout undo <deployment/deployment-name>
```
This command will revert the deployment to the previous revision.

---

## 4. **Rollback in Kubernetes**
A **rollback** refers to reverting the deployment to a previous stable version if the new rollout causes issues.

### 4.1 **Perform a Rollback**
If the rollout introduces issues, you can easily roll back to the previous version:
```bash
kubectl rollout undo <deployment/nginx-deployment>
```

### 4.2 **Rollback to a Specific Revision**
You can rollback to a specific revision in the deployment history by specifying the revision number:
```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=<revision-number>
```

### 4.3 **View Deployment Revision History**
To view the revision history and decide which revision to rollback to, use:
```bash
kubectl rollout history deployment/nginx-deployment
```
This command shows the list of all previous revisions and their change causes (if any were recorded).

### 4.4 **Record Changes** (Optional)
To record the cause of the rollout (e.g., why the update was made), you can annotate the deployment or use the deprecated `--record` flag. Example of annotating with a custom cause:
```bash
kubectl annotate deployment nginx-deployment change-cause="Updated nginx image to 1.24"
```

---

## 5. **Best Practices for Rollout and Rollback**
Here are some best practices for managing Kubernetes deployments with rollouts and rollbacks:

### 5.1 **Use a Rolling Update Strategy**
Always use the `RollingUpdate` strategy in your deployments to ensure zero-downtime updates. This allows for gradual pod replacement without service interruption.

Example:
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
```

### 5.2 **Monitor the Rollout Progress**
Always monitor the progress of your rollout. Use `kubectl rollout status` to ensure the update is happening smoothly.

### 5.3 **Test Before Rolling Out**
Before performing a rollout to production, test the new version of your application in a staging or development environment. This helps catch potential issues early.

### 5.4 **Limit Maximum Unavailable Pods**
Set `maxUnavailable` to 1 or a low value to ensure at least some pods remain running during the rollout process. This helps to prevent service disruption during the update.

### 5.5 **Rollbacks Should Be Swift**
If you notice issues after a rollout, rollback quickly to minimize downtime and ensure stability. Use `kubectl rollout undo` to revert changes immediately.

---

## 6. **Troubleshooting**
If you face issues during a rollout or rollback, use the following commands for troubleshooting:

- **Check Pod Logs**:
  ```bash
  kubectl logs <pod-name>
  ```

- **View all the Deployment**:
  ```bash
  kubectl get deployment
  ```
  
- **Describe the Deployment**:
  ```bash
  kubectl describe deployment <deployment Name>
  ```

- **Check the Pod Events**:
  ```bash
  kubectl get events --sort-by='.lastTimestamp'
  ```
These commands provide detailed insights into the state of your application and help you identify the root cause of any issues.
