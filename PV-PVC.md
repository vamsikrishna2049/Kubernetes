In Kubernetes (K8s), **Persistent Volumes (PVs)** and **Persistent Volume Claims (PVCs)** are objects used to manage storage for applications. They abstract the underlying storage infrastructure and provide a way to request and allocate persistent storage for your containers. Below are the detailed steps on how to use **PV** and **PVC** in Kubernetes.

# Example at Below

### 1. **Understanding PV (Persistent Volume)**
A **Persistent Volume (PV)** is a piece of storage in the Kubernetes cluster that has been provisioned by an administrator or dynamically provisioned using storage classes. A PV can be backed by different types of storage solutions, such as local disks, cloud storage (e.g., AWS EBS, GCP Persistent Disk), NFS, or more advanced storage systems.

#### Key Components of a PV:
- **Capacity**: Specifies the size of the volume (e.g., `10Gi`).
- **Access Modes**: Describes how the volume can be accessed. Common modes are:
  - `ReadWriteOnce` (RWO) - Can be mounted as read-write by a single node.
  - `ReadOnlyMany` (ROX) - Can be mounted as read-only by many nodes.
  - `ReadWriteMany` (RWX) - Can be mounted as read-write by many nodes.
- **Reclaim Policy**: Defines what happens when a PVC is deleted. Possible options:
  - `Retain`: The PV is not deleted, even after the PVC is deleted.
  - `Delete`: The PV is automatically deleted when the PVC is deleted.
  - `Recycle`: The PV is cleaned up and made available for reuse (this is deprecated).
- **Storage Class**: Defines the storage type (e.g., `standard` or `fast`).
- **Provisioner**: Defines the plugin that manages the volume, like AWS, GCP, etc.

### 2. **Understanding PVC (Persistent Volume Claim)**
A **Persistent Volume Claim (PVC)** is a request for storage by a user. It specifies the amount of storage, access mode, and storage class. A PVC is bound to a PV that matches the requested requirements. PVCs allow users to abstract away the details of the underlying storage.

#### Key Components of a PVC:
- **Requests**: Specifies the amount of storage required (e.g., `10Gi`).
- **Access Modes**: Specifies how the volume can be accessed (same as PV access modes).
- **Storage Class**: Optionally specifies the storage class to use for dynamic provisioning.
- **Volume Mode**: Defines whether the volume will be used as a file system (`Filesystem`) or block device (`Block`).

---

### Detailed Steps to Create and Use PV and PVC

#### Step 1: **Create a Persistent Volume (PV)**
A PV can be statically provisioned, which means that an administrator creates the volume manually. Here's an example of creating a **PV** using YAML.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /mnt/data
```

Explanation:
- **capacity.storage**: The amount of storage available on this volume.
- **accessModes**: Specifies that this volume can only be mounted by a single node for read/write access.
- **persistentVolumeReclaimPolicy**: This is set to `Retain`, so the volume will not be deleted when the PVC is deleted.
- **hostPath**: This is used for local storage, where `/mnt/data` is the path on the node's file system.

Apply the PV configuration with:

```bash
kubectl apply -f pv.yaml
```

#### Step 2: **Create a Persistent Volume Claim (PVC)**
Once the PV is created, you need a **PVC** to request the storage. Here’s an example YAML for creating a **PVC**:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard
```

Explanation:
- **accessModes**: Matches the access mode of the PV (in this case, `ReadWriteOnce`).
- **resources.requests.storage**: The amount of storage required, which should match or be less than the size of the PV.
- **storageClassName**: If you don’t specify this, it will default to the `default` storage class, but here it’s explicitly set to `standard`.

Apply the PVC configuration with:

```bash
kubectl apply -f pvc.yaml
```

#### Step 3: **PVC Bound to a PV**
Once the PVC is created, Kubernetes will try to match it with a suitable **PV**. If the **PV** matches the criteria specified in the PVC (capacity, access modes, and storage class), the PVC will be bound to the PV. You can check the binding status with:

```bash
kubectl get pvc
```

The output should show something like:

```
NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
my-pvc    Bound    my-pv    10Gi       RWO            standard       1m
```

If the status is `Bound`, it means the PVC has successfully bound to the PV.

#### Step 4: **Using PVC in a Pod**
Now, you can use the **PVC** in a pod definition to mount the volume. Here’s an example of how to use the **PVC** in a pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: my-container
      image: nginx
      volumeMounts:
        - mountPath: /usr/share/nginx/html
          name: my-storage
  volumes:
    - name: my-storage
      persistentVolumeClaim:
        claimName: my-pvc
```

Explanation:
- **volumeMounts**: Specifies where to mount the persistent volume inside the container (`/usr/share/nginx/html` in this case).
- **volumes**: The volume uses the `persistentVolumeClaim` field to refer to the PVC `my-pvc`.

Apply the pod configuration:

```bash
kubectl apply -f pod.yaml
```

#### Step 5: **Verify the PVC and PV Usage**
After the pod is running, you can verify that the PVC and PV are being used correctly.

```bash
kubectl get pod my-pod
kubectl describe pvc my-pvc
kubectl describe pv my-pv
```

These commands will show the status of the pod, PVC, and PV, including details about their bindings and usage.

---

### Dynamic Provisioning (Optional)

If you want to avoid manually creating PVs, Kubernetes can automatically provision persistent storage using **StorageClasses**. This allows Kubernetes to automatically create PVs based on a PVC's request.

Here’s how you can set up dynamic provisioning:

1. **Create a StorageClass**: A **StorageClass** defines the type of storage and the provisioner used to dynamically create PVs.
   Example of a **StorageClass** definition:

   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: fast
   provisioner: kubernetes.io/aws-ebs
   parameters:
     type: gp2
   ```

   This storage class will use AWS EBS volumes with the `gp2` type.

2. **Create a PVC with the StorageClass**: When creating a PVC, you can specify the `storageClassName` to use dynamic provisioning.

   Example PVC using dynamic provisioning:

   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: dynamic-pvc
   spec:
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 10Gi
     storageClassName: fast
   ```

   When this PVC is created, Kubernetes will dynamically provision a new EBS volume and bind it to the PVC.

---

### Step 6: **Reclaim Policy and PVC Deletion**
When a PVC is deleted, the **PersistentVolume (PV)** will be affected depending on its **reclaim policy**:

- **Retain**: The PV is not deleted and can be reused manually.
- **Delete**: The PV is automatically deleted, along with its underlying storage.
- **Recycle**: The PV is cleaned and made available for reuse (deprecated in Kubernetes).

If you want to clean up the PVC, you can simply delete it:

```bash
kubectl delete pvc my-pvc
```

If the PV has the `Delete` reclaim policy, the associated volume will also be deleted.

---



```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ebs-pv
spec:
  capacity:
    storage: 10Gi  # Size of the EBS volume
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce  # Can be mounted as read-write by a single node
  persistentVolumeReclaimPolicy: Retain  # Optionally: Retain, Recycle, or Delete
  storageClassName: standard  # Must match the storage class if used
  awsElasticBlockStore:
    volumeID: "vol-009ae47f050c7986e"  # EBS Volume ID
    fsType: ext4  # File system type (ext4 is commonly used)

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi  # Size of the storage you need
  storageClassName: standard  # Should match with the PV StorageClass


apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: ebs-storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: ebs-storage
    persistentVolumeClaim:
      claimName: ebs-pvc
```

### Conclusion
1. **Persistent Volumes (PVs)** represent actual storage resources in the Kubernetes cluster.
2. **Persistent Volume Claims (PVCs)** are used by applications to request specific storage resources.
3. PVs can be manually created or dynamically provisioned using StorageClasses.
4. PVCs bind to PVs based on size, access mode, and storage class.
5. Kubernetes can manage the lifecycle of PVs and PVCs, making storage management simpler and more flexible.

This detailed workflow allows you to set up persistent storage in Kubernetes for stateful applications, ensuring that your data persists even if the containers are destroyed and recreated.
