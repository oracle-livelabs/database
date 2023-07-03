# Generate the Kubeconfig File

"Invention, my dear friends, is 93% perspiration, 6% electricity, 4% evaporation, and 2% butterscotch ripple."
\- Willy Wonka

## Introduction

This lab will walk you through establishing a connection to the Kubernetes cluster by generating a `kubeconfig` file.

*Estimated Lab Time:* 1 minute

Watch the video below for a quick walk through of the lab.
[](youtube:zNKxJjkq0Pw)

### Objectives

* Establish a connection and interact with the cluster

### Prerequisites

This lab assumes you have:

* An accessible Oracle Kubernetes Engine Cluster provisioned

## Task 1: Create the Kubeconfig file

The Kubernetes command-line tool, `kubectl`, relies on the "Kubeconfig file" for logging in and working with Kubernetes clusters.  The kubeconfig file holds important details like cluster info, login methods, and user credentials.

In OCI, navigate to Developer Services -> Kubernetes Clusters(OKE).

![OCI OKE Navigation](images/oci_oke_nav.png "OCI OKE Navigation")

Select your cluster and click the "Access Cluster" button. Follow the steps to "Manage the cluster via Cloud Shell".

![OCI Create Kubeconfig](images/oci_create_kubeconfig.png "OCI Create Kubeconfig")

Paste the copied command into Cloud Shell.  This will create a configuration file, the `kubeconfig`, that `kubectl` uses to access the cluster in the default location of `$HOME/.kube/config`.

## Task 2: Test Kubernetes Access

Just as with `srvctl`, used to query the resources in a Oracle Grid Infrastructure Cluster in RAC Clusters, use `kubectl` to query the resources in the K8s cluster.

In Cloud Shell:

```bash
<copy>
kubectl get all -A
</copy>
```

The command should return all the resources in the K8s cluster.  If an error is returned, ensure the K8s cluster is up and running and that the `kubeconfig` file was properly generated in *Task 1*.

![kubectl get all -A](images/kubectl_get_all.png "kubectl get all -A")

## Task 3: Change the default Namespace Context

With kubeconfig files, you can organize your clusters, users, and namespaces. You can also define contexts to quickly and easily switch between clusters and namespaces.

Take a look at your existing configuration and default context, in Cloud Shell:

```bash
<copy>
kubectl config view --minify
</copy>
```

You will only have one context defined, but suppose you have a development and test cluster.  In the development cluster you work in your own namespace and in the test cluster all DBAs share the same namespace.  Additionally, the development cluster permits username/password authentication, while in the test cluster, you must use a certificate.

![Kubeconfig Context](images/kubeconfig_context.png "Kubeconfig Context")

All this information can be stored in a single kubeconfig file and you can define a `context` to group the cluster, user AuthN, and namespace together.

Rename the existing context to `development`:

```bash
<copy>
kubectl config rename-context $(kubectl config current-context) development
</copy>
```

Create a new context and call it `test`:

```bash
<copy>
kubectl config set-context test \
--namespace=dba-team \
--cluster=$(kubectl config get-clusters | tail -1) \
--user=$(kubectl config get-users | tail -1)
</copy>
```

You should now have two contexts, one named development and one named test:  

```bash
<copy>
kubectl config view --minify
</copy>
```

Although in our example both contexts point to the same user and cluster, you can see how easy it is create different isolated environments.  Switching between clusters, users, and/or namespaces would simply involve changing the context, for example: `kubectl config use-context development`.

For Production clusters, you may consider storing its context in an entirely different kubeconfig file to limit access and prevent mistakes.  Using the `production` context would be a matter of setting the `KUBECONFIG` environment variable to its location.

## Learn More

* [Command line tool (kubectl)](https://kubernetes.io/docs/reference/kubectl/)
* [Organizing Cluster Access Using kubeconfig Files](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/)

## Acknowledgements

* **Author** - John Lathouwers, Developer Advocate, Database Development Operations
* **Last Updated By/Date** - John Lathouwers, May 2023
