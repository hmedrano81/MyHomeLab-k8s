# Kubernetes Ingress Controller Tutorial

## Introduction
This tutorial will guide you through the process of setting up an Ingress Controller in a Kubernetes cluster. An Ingress Controller is responsible for managing access to your services from outside the Kubernetes cluster.

## Prerequisites
- A running Kubernetes cluster
- `kubectl` command-line tool configured to communicate with your cluster

## Step 1: Install an Ingress Controller
There are several Ingress Controllers available. In this tutorial, we will use NGINX Ingress Controller.

### Using Helm
If you have Helm installed, you can install the NGINX Ingress Controller with the following command:
```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
```

### Without Helm
You can also install the NGINX Ingress Controller using a Kubernetes manifest:
```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

## Step 2: Verify the Installation
Check that the Ingress Controller pods are running:
```sh
kubectl get pods -n ingress-nginx
```

## Step 3: Create an Ingress Resource
Create a file named `ingress.yaml` with the following content:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    name: example-ingress
    namespace: default
spec:
    rules:
    - host: example.com
        http:
            paths:
            - path: /
                pathType: Prefix
                backend:
                    service:
                        name: example-service
                        port:
                            number: 80
```

Apply the Ingress resource:
```sh
kubectl apply -f ingress.yaml
```

## Step 4: Test the Ingress
Ensure that your DNS is configured to point `example.com` to the Ingress Controller's external IP. You can then access your service using the domain `example.com`.

## Conclusion
You have successfully set up an Ingress Controller and created an Ingress resource to manage external access to your services. For more advanced configurations, refer to the official documentation of the Ingress Controller you are using.
