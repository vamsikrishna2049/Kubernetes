```bash
root@ip-10-0-30-240:~# kubectl rollout history deployment/nginx-latest -n test-webapp
deployment.apps/nginx-latest
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
4         <none>
```

### In order to get the Change-cause use annotations.
## Command way
```bash
kubectl annotate deployment nginx-latest -n test-webapp change-cause="Updated to nginx:latest for security patch" --overwrite
```


## Manifestfile (mention under the meta-data section i.e., meta-data.annotations)

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-latest
  namespace: test-webapp
  annotations:
    change-cause: "Updated to nginx:latest for security patch"
spec:
  replicas: 10
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
        image: nginx:latest  # Specify the updated image version
        ports:
        - containerPort: 80
