### Kubernetes Probes: Overview

In Kubernetes, **probes** are used to monitor the health and readiness of containers running within pods. They help Kubernetes decide when to restart a container or when it is ready to serve traffic. Probes ensure that containers are running correctly and that the system is resilient to failures.

There are three types of probes in Kubernetes:

1. **Liveness Probe**
2. **Readiness Probe**
3. **Startup Probe**

Each probe serves a different purpose and can be configured with different methods (e.g., HTTP request, TCP socket, or executing a command).

### 1. **Liveness Probe**

- **Purpose**: The **liveness probe** checks if a container is still alive or has entered a state where it cannot recover (e.g., deadlock or an unresponsive state).
  - If the liveness probe fails, Kubernetes will kill the container and attempt to restart it based on the **restart policy** defined in the pod specification.
  - This is crucial to ensure that containers are not running indefinitely in a faulty state.

- **How It Works**:
  - The liveness probe is configured with a specific check, such as:
    - **HTTP request**: Kubernetes sends an HTTP GET request to a specific endpoint inside the container.
    - **TCP socket**: Kubernetes attempts to establish a TCP connection to a port inside the container.
    - **Exec command**: Kubernetes runs a command inside the container and expects a specific exit code.

- **Example Configuration** (HTTP Request):
  ```yaml
  livenessProbe:
    httpGet:
      path: /healthz
      port: 8080
    initialDelaySeconds: 3
    periodSeconds: 3
    timeoutSeconds: 2
    failureThreshold: 3
  ```

  In this example, Kubernetes sends an HTTP GET request to `/healthz` on port `8080`. If the probe fails (i.e., if the HTTP request does not return a success status), it will trigger a restart.

---

### 2. **Readiness Probe**

- **Purpose**: The **readiness probe** checks if a container is **ready to serve traffic**. This is used to ensure that a container is fully initialized and capable of handling requests before Kubernetes starts routing traffic to it.
  - If the readiness probe fails, Kubernetes will not send traffic to the container, but it will not kill the container.
  - This is particularly useful during the startup phase or for containers that have a slow initialization process.

### How the Readiness Probe Works Internally:
Internally, the Readiness Probe is part of the **Pod lifecycle** and interacts with the **Kubelet** and **Service** components of Kubernetes. Here’s a breakdown of how it works:

1. **Configuration**: 
   You configure the Readiness Probe in your pod’s specification (typically in the `spec.containers.readinessProbe` field). There are three common types of readiness probes you can use:
   - **HTTP GET Probe**: The Kubelet makes an HTTP request to a specified path on the container. If the HTTP response code is in the range 200-399, the container is considered ready.
   - **TCP Socket Probe**: The Kubelet tries to open a TCP connection to a specified port on the container. If the connection is successful, the container is considered ready.
   - **Exec Probe**: The Kubelet executes a command inside the container. If the command exits with a status of `0` (success), the container is considered ready.

2. **Initialization**: 
   When the Pod starts, the Kubelet begins monitoring the readiness state of the container using the configured readiness probe. If the probe is configured with parameters such as `initialDelaySeconds`, `timeoutSeconds`, `periodSeconds`, and `failureThreshold`, the Kubelet will apply them to control the timing and frequency of probe attempts.

3. **Periodic Checks**:
   After the pod starts, the Kubelet performs periodic checks based on the interval set in the probe (`periodSeconds`). For example, if the `periodSeconds` is set to `10`, the Kubelet will check the probe every 10 seconds.

4. **Success/Failure Logic**:
   - **Success**: If the probe passes successfully (based on the type of probe), the container is marked as **Ready**. This means the container can start receiving traffic through Kubernetes services, and any existing traffic will be routed to the pod.
   - **Failure**: If the probe fails, the container is marked as **Not Ready**. If a container fails the readiness probe multiple times, the pod is considered **unready** and will not receive traffic from services or ingress resources.

5. **Effects on Traffic Routing**:
   - If a pod is marked as **Not Ready**, Kubernetes will not send traffic to it through Services (or Ingress) associated with that pod. It ensures that traffic is only routed to containers that are ready to handle it.
   - When the container eventually passes the readiness probe, it is marked as **Ready**, and traffic will again be routed to it.

6. **Impact on Pod Lifecycle**:
   - A pod that is **Not Ready** can still be running and performing tasks, but it won't be part of the load balancing for traffic.
   - The probe can help with graceful rollouts: When a new version of a container is deployed, the readiness probe ensures that traffic is only sent to the new pod when it is ready, preventing incomplete or broken versions from receiving requests.

### Readiness Probe Example:

```apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 2
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
        image: myapp-image
        ports:
          - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /healthz          # HTTP GET request to check if the app is ready
            port: 8080
          initialDelaySeconds: 5    # Wait 5 seconds after container start before checking
          periodSeconds: 10         # Check every 10 seconds
          timeoutSeconds: 3         # Give up after 3 seconds if no response
          failureThreshold: 3       # Mark as unready after 3 failed attempts
          successThreshold: 1       # Need 1 successful check to be considered ready

      - name: myapp-container-tcp
        image: myapp-image
        ports:
          - containerPort: 8081    # A different port for this container to check
        readinessProbe:
          tcpSocket:
            port: 8081              # TCP connection check on port 8081
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 3
          successThreshold: 1

      - name: myapp-container-exec
        image: myapp-image
        ports:
          - containerPort: 8082
        readinessProbe:
          exec:
            command:
              - "/bin/sh"
              - "-c"
              - "curl -f http://localhost:8082/healthz"  # Execute a command to check readiness
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 3
          successThreshold: 1
```

### Full Example YAML with All Three Types of Readiness Probes:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 2
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
        image: myapp-image
        ports:
          - containerPort: 8080
        readinessProbe:
          httpGet:
            path: /healthz          # HTTP GET request to check if the app is ready
            port: 8080
          initialDelaySeconds: 5    # Wait 5 seconds after container start before checking
          periodSeconds: 10         # Check every 10 seconds
          timeoutSeconds: 3         # Give up after 3 seconds if no response
          failureThreshold: 3       # Mark as unready after 3 failed attempts
          successThreshold: 1       # Need 1 successful check to be considered ready

      - name: myapp-container-tcp
        image: myapp-image
        ports:
          - containerPort: 8081    # A different port for this container to check
        readinessProbe:
          tcpSocket:
            port: 8081              # TCP connection check on port 8081
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 3
          successThreshold: 1

      - name: myapp-container-exec
        image: myapp-image
        ports:
          - containerPort: 8082
        readinessProbe:
          exec:
            command:
              - "/bin/sh"
              - "-c"
              - "curl -f http://localhost:8082/healthz"  # Execute a command to check readiness
          initialDelaySeconds: 5
          periodSeconds: 10
          timeoutSeconds: 3
          failureThreshold: 3
          successThreshold: 1
```

### Breakdown of the YAML Example:

1. **HTTP GET Readiness Probe**:
   - **Type**: `httpGet`
   - **Path**: `/healthz` — The Kubelet sends an HTTP GET request to this path on port 8080 of the container.
   - **Behavior**: If the HTTP response code is between 200-399, the container is considered ready.
   - **Settings**:
     - `initialDelaySeconds`: Wait 5 seconds after the container starts before checking.
     - `periodSeconds`: Check readiness every 10 seconds.
     - `timeoutSeconds`: Timeout the probe if it takes more than 3 seconds.
     - `failureThreshold`: Mark the container as not ready after 3 failed probes.
     - `successThreshold`: It requires 1 successful probe to be considered ready.

2. **TCP Socket Readiness Probe**:
   - **Type**: `tcpSocket`
   - **Port**: `8081` — The Kubelet attempts to establish a TCP connection to the container on port 8081.
   - **Behavior**: If the TCP connection is successful, the container is marked as ready.
   - **Settings**:
     - Similar to the HTTP GET probe, but instead of an HTTP request, it checks the ability to establish a TCP connection.
     - The parameters are the same for `initialDelaySeconds`, `periodSeconds`, `timeoutSeconds`, `failureThreshold`, and `successThreshold`.

3. **Exec Command Readiness Probe**:
   - **Type**: `exec`
   - **Command**: Executes the command `curl -f http://localhost:8082/healthz` to check the health of the container. The command is executed inside the container, and if it returns a successful exit code (`0`), the container is considered ready.
   - **Behavior**: If the command executes successfully (exit code `0`), the container is considered ready. If the command fails (non-zero exit code), the container is marked as not ready.
   - **Settings**: The same timing and failure logic are applied as with the other probes.

### Key Parameters for Each Probe:

- **`initialDelaySeconds`**: The time the Kubelet will wait before starting the first readiness probe after the container starts.
- **`periodSeconds`**: How often the probe will be performed (in seconds).
- **`timeoutSeconds`**: How long the Kubelet will wait for the probe to complete before considering it as failed.
- **`failureThreshold`**: The number of consecutive failed probes before the container is marked as **Not Ready**.
- **`successThreshold`**: The number of consecutive successful probes before the container is marked as **Ready**.

### Use Case for Each Probe:

- **HTTP GET Probe**: Typically used for web servers or HTTP-based services, where a simple path like `/healthz` can indicate readiness.
- **TCP Socket Probe**: Useful when you want to check if a port is open and accepting TCP connections, without relying on HTTP.
- **Exec Command Probe**: Ideal for custom commands or scripts that need to run inside the container to determine if the application is ready.

### Example with Health Check Routes:

For the HTTP and Exec probes to work, your application inside the container must have a health check endpoint or mechanism to indicate whether it's ready to serve traffic. For example:

1. **HTTP Health Check**: You can create an HTTP endpoint like `/healthz` in your application that returns a 200 OK status when the app is ready.
2. **Exec Command**: The `exec` command can check any necessary condition inside the container, such as verifying a service is running or checking if a required file exists.

For instance, in a Python Flask application, you could have a health check like this:

```python
from flask import Flask

app = Flask(__name__)

@app.route('/healthz')
def health_check():
    return "OK", 200

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
```

This `/healthz` endpoint would work for the **HTTP GET** readiness probe.

### How Kubernetes Responds to a Failed Readiness Probe:
- When a container is marked as **Not Ready** due to failing the readiness probe, Kubernetes will **remove the container from the Service endpoints**. This means it will not receive traffic from any associated Kubernetes Service, until it is marked as **Ready**.
- **Pod Termination**: If a pod has a readiness probe configured and it fails over a period, the Kubernetes system will not terminate the pod, as it is still considered "running." However, it will stop routing traffic to that pod, and in the case of updates or rollouts, it ensures that only "Ready" pods are used in serving traffic.

### Use Cases for Readiness Probes:
1. **Service Initialization**: Some applications need a warm-up period before they can handle traffic, such as database connections or background task setup.
2. **Slow-starting applications**: Applications with long initialization processes (e.g., large machine learning models or complex web applications) might benefit from readiness probes to avoid sending traffic before they’re ready.
3. **Graceful shutdowns**: During pod updates, readiness probes ensure that the old pod doesn’t receive new traffic while it is being gracefully shut down.

In summary, the **readiness probe** is an essential part of ensuring that containers in Kubernetes are only serving traffic when they are fully ready to handle it. The probe runs periodically, checking conditions defined by the user (HTTP, TCP, or Exec), and based on the probe results, Kubernetes adjusts the pod's readiness state, impacting whether traffic is routed to the pod.


---

### 3. **Startup Probe**

- **Purpose**: The **startup probe** is used to determine if the container has started successfully. It is particularly useful for applications that take a long time to start up.
  - If the startup probe fails, Kubernetes will kill the container and restart it.
  - This probe is generally used in combination with liveness and readiness probes to handle cases where the startup time of a container is longer than expected.

- **How It Works**:
  - The startup probe is like a liveness probe, but it only runs during the startup phase. It helps to distinguish between normal startup delays and actual application failures.
  - It ensures that the container is not prematurely killed during startup due to slow initialization.
---

### Probe Parameters

Each probe (liveness, readiness, startup) has several configuration parameters that define its behavior:

- **`initialDelaySeconds`**: The time to wait before the first probe is initiated after the container has started.
- **`timeoutSeconds`**: The maximum amount of time allowed for the probe to complete. If the probe does not complete within this time, it is considered a failure.
- **`periodSeconds`**: The interval between consecutive probes.
- **`failureThreshold`**: The number of consecutive probe failures required to consider the container unhealthy (for liveness and startup probes) or not ready (for readiness probes).
- **`successThreshold`**: The number of consecutive successes required to consider the container healthy (for liveness and startup probes) or ready (for readiness probes).

---

### Example of a Pod with All Three Probes

Here’s an example of how you can configure all three probes in a Kubernetes pod definition:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
  - name: my-container
    image: my-app-image
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 3
      periodSeconds: 3
      timeoutSeconds: 2
      failureThreshold: 3
    readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 2
      failureThreshold: 3
    startupProbe:
      httpGet:
        path: /startup
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5
      failureThreshold: 3
      timeoutSeconds: 2
```

In this example:
- The **liveness probe** checks if the app is alive by sending an HTTP GET request to `/healthz`.
- The **readiness probe** ensures the app is ready to serve traffic by attempting to connect to port `8080`.
- The **startup probe** checks if the app has successfully started by sending an HTTP GET request to `/startup`.

---

### Key Takeaways

- **Liveness Probes**: Ensure containers are alive and restart them if they are not.
- **Readiness Probes**: Ensure containers are ready to serve traffic and prevent traffic routing to containers that are not fully initialized.
- **Startup Probes**: Specifically for applications with long startup times to avoid premature restarts.

By using probes in Kubernetes, you can ensure that your applications are running healthily, responding correctly to traffic, and able to recover from failures automatically.
