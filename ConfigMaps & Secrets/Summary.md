Kubernetes (K8s) deployment that connects to an AWS RDS PostgreSQL database using **Secrets** for sensitive information (like passwords) and **ConfigMaps** for non-sensitive configuration (like the database host, port, and name).

### Step-by-Step Process

#### **Step 1: Prerequisites**
Ensure you have the following setup:
- **Kubernetes Cluster** Running (either on a cloud provider like AWS or locally using Minikube).
- **Kubectl** installed and configured to interact with your Kubernetes cluster.
- **AWS RDS PostgreSQL** instance running and accessible.

#### Note: Make sure AWS RDS and K8S must be in same VPC. Else you need to establish a peer Connection in between 2 different VPC's.

#### **Step 2: Create a Kubernetes Secret for Sensitive Information**

1. **Why a Secret?**
   Secrets are used to store sensitive data like database usernames and passwords.

2. **Create the Secret**:
   You will store your PostgreSQL credentials (username and password) in a Kubernetes Secret. Run the following command:

   ```bash
   kubectl create secret generic postgres-credentials \
     --from-literal=POSTGRES_USER=postgres \
     --from-literal=POSTGRES_PASSWORD='yourpassword'
   ```
##### Note:
   Replace `yourpassword` with your actual PostgreSQL password.

3. **Verify the Secret**:
   You can verify the Secret creation by running:

   ```bash
   kubectl get secret postgres-credentials -o yaml
   ```

   This will show the details of the Secret (the password will be base64 encoded).

#### **Step 3: Create a Kubernetes ConfigMap for Non-Sensitive Configuration**

1. **Why a ConfigMap?**
   ConfigMaps are used to store non-sensitive data, such as database host, port, and database name.

2. **Create the ConfigMap**:
   Store your PostgreSQL database configuration (host, port, database name) in a ConfigMap. Run the following command:

   ```bash
   kubectl create configmap postgres-config \
     --from-literal=POSTGRES_HOST=database-1.ctsmim8wsqwe.us-east-1.rds.amazonaws.com \
     --from-literal=POSTGRES_PORT=5432 \
     --from-literal=POSTGRES_DB=database-1
   ```

   Replace the `POSTGRES_HOST` and `POSTGRES_DB` values with your actual AWS RDS endpoint and database name.

3. **Verify the ConfigMap**:
   You can verify the ConfigMap creation by running:

   ```bash
   kubectl get configmap postgres-config -o yaml
   ```

   This will show the details of the ConfigMap.

#### **Step 4: Create the Kubernetes Deployment**

1. **Define the Deployment YAML**:
   Now, create a Kubernetes Deployment that will reference the **Secret** for the sensitive PostgreSQL credentials and the **ConfigMap** for the database configuration.

   Create a file called `myapp-deployment.yaml` and add the following content:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-client
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-client
  template:
    metadata:
      labels:
        app: postgres-client
    spec:
      containers:
      - name: postgres-client-container
        image: postgres:latest   # Using the official PostgreSQL image
        command: ["sleep", "3600"]  # Keeps the pod running to allow manual connection via exec
        env:
        # Load sensitive values from the secret
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: POSTGRES_USER
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgres-credentials
              key: POSTGRES_PASSWORD
        # Load non-sensitive values from the ConfigMap
        - name: POSTGRES_HOST
          valueFrom:
            configMapKeyRef:
              name: postgres-config
              key: POSTGRES_HOST
        - name: POSTGRES_PORT
          valueFrom:
            configMapKeyRef:
              name: postgres-config
              key: POSTGRES_PORT
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: postgres-config
              key: POSTGRES_DB
        ports:
        - containerPort: 80
```

   **Explanation**:
   - The `POSTGRES_USER` and `POSTGRES_PASSWORD` environment variables are loaded from the **Secret**.
   - The `POSTGRES_HOST`, `POSTGRES_PORT`, and `POSTGRES_DB` environment variables are loaded from the **ConfigMap**.
   - Replace `your-image:latest` with the actual Docker image for your application.

2. **Apply the Deployment**:
   Apply the Deployment to your Kubernetes cluster by running:

   ```bash
   kubectl apply -f myapp-deployment.yaml
   ```

#### **Step 5: Verify the Deployment**

1. **Check the Pods**:
   Run the following command to check if your pod is running:

   ```bash
   kubectl get pods
   ```

2. **View Logs**:
   Once the pod is up and running, you can view the logs to check if your application successfully connected to the PostgreSQL database. Use the following command:

   ```bash
   kubectl logs <pod-name>
   ```

   Replace `<pod-name>` with the actual name of your pod (you can get the pod name by running `kubectl get pods`).

#### **Step 6: Verify Database Connection Inside the Pod (Optional)**

To ensure that your pod can connect to the PostgreSQL database, you can run a shell inside your pod and test the connection.

1. **Exec into the Pod**:
   ```bash
   kubectl exec -it <pod-name> -- /bin/bash
   ```

2. **Check PostgreSQL Connection** (using `psql`):
   Inside the pod, use the following command to connect to the PostgreSQL database:
   ```bash
   psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -p $POSTGRES_PORT
   ```
   You should be able to connect to your PostgreSQL database if everything is set up correctly.

3. Try pinging the RDS instance:
```bash
ping database-1.ctsmim8wsqwe.us-east-1.rds.amazonaws.com
```

4. Check if Kubernetes Pod is Running in the Same VPC/Subnet


#### **Step 7: Clean Up (Optional)**
If you want to delete the resources you created, you can use the following commands:

1. **Delete the Deployment**:

   ```bash
   kubectl delete -f myapp-deployment.yaml
   ```

2. **Delete the Secret**:

   ```bash
   kubectl delete secret postgres-credentials
   ```

3. **Delete the ConfigMap**:

   ```bash
   kubectl delete configmap postgres-config
   ```

---

### Conclusion

You now have a step-by-step process to securely connect a Kubernetes pod to an AWS RDS PostgreSQL database using **Secrets** for sensitive information and **ConfigMaps** for non-sensitive configuration.

- **Secrets** store sensitive data like usernames and passwords.
- **ConfigMaps** store configuration data like database host, port, and name.
- The **Deployment** YAML uses both to configure your application.

This approach ensures that your database credentials and configuration are securely managed within Kubernetes. Let me know if you need more assistance!
