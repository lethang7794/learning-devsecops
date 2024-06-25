# Chap 7. Plan and Expand

## Scaling Up with Kubernetes

- Docker: VM -> Container
- Docker Compose: Multi containers
- K8s: A lot of containers (thousands) -> Container orchestration

### Understanding Basic Kubernetes Terms

#### Kubernetes's architecture:

- Control plane(s):
  - A key/value store - `etcd`
  - An API server - `kube-apiserver`
  - A controller manager - `kube-controller` - responsible for node/job management...
  - A scheduler - `kube-scheduler` - responsible for containers management
- Worker node(s):
  - An agent - `kubelet`
  - A proxy - `kube-proxy`: responsible for network communication
  - A container runtime, e.g.
    - `containerd`: The original one by Docker
    - `cri-o`: Open Container Initiative-based implementation of Container Runtime Interface for Kubernetes
    - `cri-dockerd`: dockerd as a compliant Container Runtime Interface for Kubernetes

#### Kubernetes concepts

cluster
: the components that constitutes an entire Kubernetes installation

pod
: a group of containers

service
: ~ a network-based listening service

### Create a Kubernetes cluster

- Setup your own K8s cluster with `kubeadm`[^1]
  - Install `kubeadm`
  - Create a cluster's control plane with `kubeadm init`

#### Add networking

Add networking with [Calico]

#### Add nodes to Kubernetes cluster

Join other nodes to your Kubernetes cluster with `kubeadm join`

- as worker nodes
- or as control planes

For more way to setup a Kubernetes cluster, see [Installing Kubernetes with deployment tools]

#### Re-creating the join command

When interact with the cluster, you need to provide the token for authentication.

These token is available:

- when use initialize the cluster
- via the `kubeadm token` sub-commands: `list`, `create`...

#### Remove nodes from Kubernetes cluster

Before a node can be removed, it needs to be drained so no more workload run on it.

```bash
# On the control plane
kubectl drain <node>
kubectl delete <node>

# On the node, "reset" to cleanup the node
kubeadm reset
```

## Deploying with Kubernetes

With Kubernetes, you can

- treat multiple containers as a single deployed unit - called _pod_ - (the same as Docker Compose)
- have redundancy of your pods via _replicas_

For Kubernetes, a configuration is in form of a file in YAML language, which can be treat _as code_.

### Defining a Deployment

Deployment
: enables declarative updates of Pods (and ReplicaSets)
: ~ you declare the end state (of a pod), K8s ensure the pod has that end state

#### Using a ConfigMap

ConfigMap
: holds configuration data for pods to consume

> [!NOTE]
> Isn't the while yaml file is a configuration data store in the configuration file, now there is configuration data. 🤔

e.g.

```yml
# configmap1.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: configmap-chapter7-1
# <Data> contains the configuration data
data:
  # Block scalar (2 styles: | or >): | Keep newlines (one newline at end)
  index.html: |
    <!doctype html>
    <html>
      <head>
        <title>Deployment 1</title>
      </head>
      <body>
        <h1>Served from Deployment 1</h1>
      </body>
    </html>
```

#### Creating the Deployment file

```yml
# deploy1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-chapter7-1
spec: # <DeploymentSpec> spec - "specification"
  replicas: 2 # Number of replicas
  selector: # K8s uses the selector to unify other K8s resources into this deployment
    matchLabels:
      app: nginx
  template: # <PodTemplateSpec>
    metadata:
      labels:
        app: nginx # This label will be used later
    spec: # <PodSpec>
      containers: # <>
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
          volumeMounts:
            - name: config-chapter7-1
              mountPath: /usr/share/nginx/html
      volumes:
        - name: config-chapter7-1
          configMap:
            name: configmap-chapter7-1 # Match the metadata field of configmap1.yaml
```

#### Running the Deployment

```yml
# Apply the configuration to ConfigMap resource (If the resource doesn't exist yet, K8s will create it)
kubectl apply -f configmap1.yaml

# Apply the configuration to Deployment resource
kubectl apply -f deploy1.yaml
```

#### Verifying the Deployment

- Get one/more resources

  - In ps format (default)

    ```bash
    kubectl get configmaps
    kubectl get deployments
    kubectl get pods

    kubectl get all
    ```

  - In ps format with more information

    ```bash
    kubectl get pods -o wide
    ```

  - In yaml/json format

    ```bash
    kubectl get pods -o yaml
    ```

- Get one/more resources in detail

  ```bash
  # Detail about ... all pods
  kubectl describe pods

  # ... all configmaps (all object of ConfigMap type)
  kubectl describe configmaps

  # ... a configmap named kube-root-ca.crt...
  kubectl describe configmaps/kube-root-ca.crt

  # ... any configmap with name prefix
  kubectl describe configmaps kube


  # ... any configmap with a select (label query)
  kubectl describe configmaps --selector project=awesome-project
  ```

### Defining a Service

Service
: a named **abstraction of software service** (for example, `mysql`), consisting of
: - local **port** (e.g. `3306`) that the proxy listens on,
: - the **selector** that determines _which pods will answer_ requests sent through the proxy.
: ~ K8s abstracts away your application, it is exposed only via the K8s Service to be available outside of the cluster to the world

e.g.

- The Service's configuration:

  ```yml
  # service.yaml
  apiVersion: v1
  kind: Service
  metadata:
    name: service-chapter7
  spec:
    selector:
      app: nginx # This is the label of the pods to be selected, match with the the deployment template's label
    type: NodePort
    ports:
      - name: http
        port: 80
        targetPort: 80
        nodePort: 30515
    externalIPs:
      - 192.168.1.158 # Set to the IP of the K8s controller, depends on the service type, it can be auto-assigned
  ```

- Create the service

  ```bash
  kubectl apply -f service.yaml
  ```

- Test the service

  ```bash
  curl http://192.168.1.158
  ```

### Moving Toward Microservices

Apply another set of configmap, deployment, service for another application, and you've a microservices system deploy a K8s cluster.

### Connecting the Resources

To organize the configuration files of an application, you can

- put all 3 configuration file of configmap, deployment, and service into a single configuration file, e.g. `app-a.yaml`
- or keep using multiple files with a name standard to distinguish between applications.

## Integrating Helm

> [!TIP]
> How to install a software in the old days?
>
> - Download a tar archive, e.g. gzipped
> - Unarchive
> - Build the app: `make && make install`
> - If something went wrong, `rm -rf config.cache && make clean`

Today, the industry use **package manager** to install software (& its dependencies), e.g.

- Linux: `apt`/`dpkg` on Debian/Ubuntu, `yum`/`dnf` on Fedora/RHEL
- Mac: `Homebrew`
- Windows: `winget`, `chocolatey`
- Docker's container images are also managed as packages
- Kubernetes: it's Helm

### Helm concepts

Helm chart
: a packages of pre-configured Kubernetes resources
: describe the desired state of an application, including all of the prerequisites needed to run it
: stored in chart repositories

Helm
: a tool for managing Charts
: ~ install, manage Kubernetes applications

Helm repository
: a location where packaged charts can be stored and shared.
: ~ a HTTP server that serves `index.yaml` & packaged charts.
: Beginning in Helm 3, you can use container registries with OCI support as a Helm repository
: e.g.
: - a community Helm chart repository located at Artifact Hub
: - self-maintain repo: bitnami

release
: an installation of a chart become a release
: with Helm, you can install the same chart multiple times, and have multiple releases (of the same chart)

> [!WARNING]
> Most of other package managers only allow one installation of a package.
>
> Helm acts both as a package manager (e.g. `npm`) & a version manager (e.g. `nvm`).

### Discovering Helm charts

You can search for charts:

- In community Helm repository at Artifact Hub

  `helm search hub <mysql>`

- In repo that's you added

  `helm search repo <mysql>`

Or you can use the Artifcat Hub web interface which has more information (including popularity).

## Summary

- Kubernetes:
  - What?
    - Docker: VM -> Container
    - Docker Compose: Multi containers
    - K8s: A lot of containers -> Container orchestration
  - Why?
    - Auto deploy/scaling/manage containerized applications
    - Abstract several application layers
- Kubernetes - How?
  - Deploy application
  - Troubleshoot
- Integrate Helm with Kubernetes

[^1]: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

[Installing Kubernetes with deployment tools]: https://kubernetes.io/docs/setup/production-environment/tools/
[Calico]: https://github.com/projectcalico
