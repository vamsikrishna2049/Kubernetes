
### **Secrets**

**Purpose:**
- **Secrets** are used to store sensitive information such as passwords, API keys, certificates, or tokens, and are encoded in base64 to prevent plain-text exposure.
- They provide a way to securely manage sensitive data that should not be exposed in plaintext.

**Why We Use Them:**
- **Security:** Secrets are encrypted by Kubernetes (if configured with a proper encryption provider) and are only accessible by Pods that need them, helping to keep sensitive data safe.
- **Access Control:** Secrets provide a way to restrict access to sensitive data to only authorized Pods or users.
- **Centralized Management:** Secrets allow you to store and manage sensitive data in a central location for easier maintenance and scaling.

### Example:
1. Generate the secrets in Imperative way
```bash
kubectl create secret generic postgres-credentials   \
--from-literal=POSTGRES_USER=postgres  \
 --from-literal=POSTGRES_PASSWORD='yourpassword' --dry-run=client -o yaml
```

2. Create a file named configmap.yaml
```bash
nano configmap.yaml
```

3. Update the below code (Declarative way)
```yaml  
apiVersion: v1
data:
  POSTGRES_PASSWORD: eW91cnBhc3N3b3Jk
  POSTGRES_USER: cG9zdGdyZXM=
kind: Secret
metadata:
  creationTimestamp: null
  name: postgres-credentials
```

4. Apply the ConfigMap
```bash
kubectl apply -f configmap.yaml
```

5. Create the ManifestFile for secrets
```bash
nano deployment.yaml
```

update the below code in the newly created file
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
        - containerPort: 5432
```

6. Apply the deployment
```bash
kubectl apply -f deployment.yaml
```
