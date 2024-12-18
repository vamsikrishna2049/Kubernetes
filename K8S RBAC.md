### **Kubernetes RBAC (Role-Based Access Control)**

**Role-Based Access Control (RBAC)** in Kubernetes is a method for regulating access to resources within a Kubernetes cluster based on the roles of individual users or service accounts. RBAC allows you to define and enforce what actions can be performed on which resources within a Kubernetes cluster, thereby controlling who can access, modify, or perform specific actions (e.g., `create`, `get`, `delete`, `update`, etc.) on Kubernetes resources (such as pods, services, deployments, etc.).

RBAC uses several key objects:
- **Role**: A set of permissions within a namespace.
- **ClusterRole**: A set of permissions across the entire cluster.
- **RoleBinding**: Associates a role with users or service accounts in a specific namespace.
- **ClusterRoleBinding**: Associates a ClusterRole with users or service accounts across the entire cluster.

### **Key RBAC Objects in Kubernetes**

1. **Role**:
   - A `Role` defines a set of permissions (verbs) for accessing resources within a specific **namespace**. A `Role` is scoped to a single namespace.
   - For example, a `Role` could define permissions to view or modify pods within a namespace.

   **Example of a Role**:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: Role
   metadata:
     namespace: default
     name: pod-reader
   rules:
   - apiGroups: [""]
     resources: ["pods"]
     verbs: ["get", "list"]
   ```

   - In this example, the `pod-reader` role allows the user to **get** and **list** pods in the `default` namespace.

2. **ClusterRole**:
   - A `ClusterRole` defines permissions across the **entire cluster**. It is not restricted to a specific namespace and can be used for cluster-wide resources (like nodes, persistent volumes, etc.) or for setting up permissions that should apply across namespaces.
   - You can also bind a `ClusterRole` to a specific namespace if needed.

   **Example of a ClusterRole**:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRole
   metadata:
     # Name of the ClusterRole
     name: cluster-admin
   rules:
   - apiGroups: [""]
     resources: ["pods", "services", "deployments", "namespaces"]
     verbs: ["*"]  # Full access to all resources
   ```

   - In this example, the `cluster-admin` role grants full access to resources like pods, services, deployments, and namespaces across the entire cluster.

3. **RoleBinding**:
   - A `RoleBinding` binds a specific `Role` to users or service accounts within a specific namespace. It grants the permissions defined in the `Role` to the specified subjects (users, service accounts, etc.).

   **Example of a RoleBinding**:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: RoleBinding
   metadata:
     name: read-only-pods
     namespace: default
   subjects:
   - kind: User
     name: "jane.doe"  # User's name
     apiGroup: rbac.authorization.k8s.io
   roleRef:
     kind: Role
     name: pod-reader  # Refers to the 'pod-reader' role
     apiGroup: rbac.authorization.k8s.io
   ```

   - In this example, the `RoleBinding` binds the `pod-reader` role (which allows reading pods) to a user named `jane.doe` in the `default` namespace.

4. **ClusterRoleBinding**:
   - A `ClusterRoleBinding` binds a `ClusterRole` to users or service accounts, but it applies cluster-wide, across all namespaces.

   **Example of a ClusterRoleBinding**:
   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: cluster-admin-binding
   subjects:
   - kind: User
     name: "alice"
     apiGroup: rbac.authorization.k8s.io
   roleRef:
     kind: ClusterRole
     name: cluster-admin  # Refers to the 'cluster-admin' ClusterRole
     apiGroup: rbac.authorization.k8s.io
   ```

   - This `ClusterRoleBinding` grants the `cluster-admin` role (which provides full access to the cluster) to the user `alice`.

### **RBAC Resources and Verbs**

**Kubernetes Resources**: Resources in Kubernetes that can be controlled via RBAC include Pods, Deployments, Services, Namespaces, etc. Each of these resources can have different levels of access granted by roles.

**Common Kubernetes Verbs**: Verbs in RBAC define the operations allowed on resources. Common verbs are:
- `get`: Read a resource.
- `list`: List all resources of a type.
- `create`: Create a new resource.
- `update`: Modify an existing resource.
- `delete`: Remove a resource.
- `patch`: Apply partial modifications to a resource.
- `watch`: Watch for changes to a resource.
- `*`: Represents all verbs (e.g., `verbs: ["*"]` allows all actions).

### **Examples of RBAC Configurations**

#### 1. **Giving Read-Only Access to All Pods in a Namespace**

To create a role that gives read-only access to all pods in a specific namespace (`default`), use the following role and role binding:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

Now, you can bind the role to a specific user or service account:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-binding
  namespace: default
subjects:
- kind: User
  name: "developer"  # User name
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

#### 2. **Granting Full Access to All Resources in a Namespace**

To allow full access to all resources in the `default` namespace, you can create a `ClusterRole` and bind it with a `ClusterRoleBinding`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: full-access
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods", "services", "deployments"]
  verbs: ["*"]
```

Then, bind the `Role` to a user or service account:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: full-access-binding
  namespace: default
subjects:
- kind: User
  name: "admin"  # User with full access
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: full-access
  apiGroup: rbac.authorization.k8s.io
```

### **How RBAC Works in Kubernetes**

- **Authorization**: When a user or service account attempts to perform an action, Kubernetes checks whether the request matches any of the **RoleBindings** or **ClusterRoleBindings** defined in the cluster.
- **Policy Evaluation**: Kubernetes evaluates whether the subject (e.g., user, service account) has the necessary permissions (verbs) to perform the requested action on the resource.
- **Access Control**: If the subject is authorized to perform the action (based on RBAC policy), Kubernetes allows the action to proceed. If not, the action is denied.

### **RBAC Best Practices**
- **Principle of Least Privilege**: Always assign the minimum required permissions for users and services to function. This helps prevent unauthorized access or accidental modifications.
- **Use `ClusterRoleBinding` carefully**: Avoid granting broad, high-level roles like `cluster-admin` unless absolutely necessary.
- **Namespaces for Isolation**: Use namespaces to isolate environments and apply RBAC on a per-namespace basis.
- **Monitor and Audit**: Regularly audit and review RBAC permissions and usage to ensure security compliance.

### **Conclusion**

RBAC in Kubernetes is a powerful tool to control access to resources in a fine-grained and secure way. By defining roles (either at the cluster level or namespace level) and binding them to users or service accounts, you can control who can perform which actions on specific Kubernetes resources. Properly configured RBAC policies are essential for securing your Kubernetes clusters and ensuring that only authorized users and services have the appropriate level of access.
