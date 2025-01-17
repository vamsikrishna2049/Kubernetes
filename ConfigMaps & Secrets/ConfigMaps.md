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
Here’s an example of creating a ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  database_url: "mysql://my-db:3306"
  app_mode: "production"
```

You can then mount this ConfigMap as environment variables or files in a Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
    - name: my-container
      image: my-image:latest
      envFrom:
        - configMapRef:
            name: my-config
```
