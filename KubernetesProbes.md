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

- **How It Works**:
  - Similar to the liveness probe, the readiness probe can be configured with different types of checks:
    - **HTTP request**
    - **TCP socket**
    - **Exec command**

- **Example Configuration** (TCP Socket):
  ```yaml
  readinessProbe:
    tcpSocket:
      port: 8080
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 2
    failureThreshold: 3
  ```

  In this example, Kubernetes attempts to open a TCP socket on port `8080`. If it is unable to connect, the container will be marked as **not ready** to handle traffic.

---

### 3. **Startup Probe**

- **Purpose**: The **startup probe** is used to determine if the container has started successfully. It is particularly useful for applications that take a long time to start up.
  - If the startup probe fails, Kubernetes will kill the container and restart it.
  - This probe is generally used in combination with liveness and readiness probes to handle cases where the startup time of a container is longer than expected.

- **How It Works**:
  - The startup probe is like a liveness probe, but it only runs during the startup phase. It helps to distinguish between normal startup delays and actual application failures.
  - It ensures that the container is not prematurely killed during startup due to slow initialization.

- **Example Configuration** (Exec Command):
  ```yaml
  startupProbe:
    exec:
      command:
        - "sh"
        - "-c"
        - "curl -f http://localhost:8080/healthz || exit 1"
    initialDelaySeconds: 10
    periodSeconds: 5
    failureThreshold: 5
    timeoutSeconds: 2
  ```

  In this example, the `startupProbe` runs a `curl` command to check if the application is ready. The probe will fail if the health check URL is not available, and the container will be restarted.

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
