### kubectl get svc
lists all the services running in your Kubernetes cluster

### kubectl port-forward svc/myapp-service 8080:80 &
Forwards port 80 from the myapp-service Kubernetes service to port 8080 on your local machine. It allows you to access the service externally using http://localhost:8080.

When you pressed Ctrl + C to stop the port forwarding process, the forwarding was stopped, and the connection to localhost:8080 was closed. 
^C

## Attempting to Restart Port Forwarding
kubectl port-forward svc/myapp-service 8080:80 &
Error: The error you encountered was caused by the fact that port 8080 is already being used by the kubectl process from the previous attempt, so it cannot bind to the same port again.

## Output:
Unable to listen on port 8080: Listeners failed to create with the following errors: [unable to create listener: Error listen tcp4 127.0.0.1:8080: bind: address already in use unable to create listener: Error listen tcp6 [::1]:8080: bind: address already in use]

### lists the processes that are currently using port 8080
sudo lsof -i :8080

## Identifying the Process:
The kubectl process (PID 5604) is using port 8080, which is why you can’t start a new port-forward session on that port.
Use sudo kill -9 5604 to terminate the existing kubectl process if necessary, or choose a different port for the new port forwarding command.
