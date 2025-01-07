# 1. Download the Metrics Server manifest:
```xml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.1/components.yaml
```

# 2. Verify the Metrics Server is working:
```xml
kubectl get deployment metrics-server -n kube-system
```

# 3. Create Deployment (Example with Nginx Deployment)
## touch nginx-deployment.yaml
```xml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
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
          image: nginx
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
          ports:
            - containerPort: 80
```

# 4. Apply Deployment
```xml
kubectl apply -f nginx-deployment.yaml
```

# 5. Verify Deployment
```xml
kubectl get deployments
```

# Step 4: Create an HPA (Horizontal Pod Autoscaler)
## 1. Create an HPA (Horizontal Pod Autoscaler) - such as scaling based on CPU or memory usage
```xml
kubectl autoscale deployment nginx-deployment --cpu-percent=50 --min=1 --max=5
```

--cpu-percent=50: The target CPU utilization percentage for each pod (50% CPU usage in this case).
--min=1: The minimum number of pods.
--max=5: The maximum number of pods.

# Verify the HPA
```xml
kubectl get hpa
```

# Alternatively, you can create a YAML definition for the HPA:
```xml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 1
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```
