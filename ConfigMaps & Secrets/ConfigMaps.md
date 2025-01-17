
### **ConfigMaps**

**Purpose:**
- **ConfigMaps** are used to store non-sensitive configuration data in key-value pairs, which can be used by Pods or other Kubernetes resources.
- The configuration data might be configuration files, environment variables, command-line arguments, etc.
- They provide a way to decouple configuration from the application code, making it easier to modify application settings without changing the code itself.

**Why We Use Them:**
- **Separation of Concerns:** ConfigMaps allow us to manage configurations separately from application logic.
- **Environment-specific Configuration:** ConfigMaps help manage environment-specific configurations (e.g., dev, test, prod) without changing the code.
- **Centralized Management:** ConfigMaps provide a centralized way to manage configuration for multiple applications or services.

**Example:**
1. Create the Configmap using Imperative way    

 ```bash
kubectl create configmap postgres-config \
--from-literal=POSTGRES_HOST=database-1.ctsmim8wsqwe.us-east-1.rds.amazonaws.com \
--from-literal=POSTGRES_PORT=5432 \
--from-literal=POSTGRES_DB=postgres
```

2. Create a file named ```configmap.yaml```
```bash
nano configmap.yaml
```

3. Update the below code (Declarative way)
```yaml
apiVersion: v1
data:
  POSTGRES_DB: postgres
  POSTGRES_HOST: database-1.ctsmim8wsqwe.us-east-1.rds.amazonaws.com
  POSTGRES_PORT: "5432"
kind: ConfigMap
metadata:
  name: postgres-config
```

4. Apply the ConfigMap
```bash
kubectl apply -f configmap.yaml
```

5. ManifestFile
```bash
nano deployment.yaml
```

update the below code in the newly created file

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp-container
        image: your-image:latest
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
