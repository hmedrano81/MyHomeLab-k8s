# Deploying a Certificate Manager in Kubernetes

Official Documentation: [Installing cert-managern](https://cert-manager.io/docs/installation/helm/

YouTube Videos: 

- [[09.01] Cert Manager](https://www.youtube.com/watch?v=39bcU68nZms&list=PLVBNl4E-lnBJR9UwFd5w05ama_4IkV-8I&index=10)

- [Kubernetes - On prem install - Load Balancer and Ingress Controller](https://www.youtube.com/watch?v=9iJLw7pUCIk)

## Prerequisites
- A running Kubernetes cluster
- `kubectl` command-line tool configured to interact with your cluster
- `helm` command-line tool installed on your local machine

## Connectivity for Master and Worker nodes
Port	        | Protocol	| Component                 |Purpose
----------------|-----------|---------------------------|---------------------------------------------------------------------------------------|
10260	        | TCP   	| Webhook	                | Webhooks are commonly used for admission control and validation, default port changed |

## Download the jetstack/cert-manager Helm Repository and modify the configuration

- From your laptop with access the the Kubernetes Cluster, add the Jetstack repository and update it.

    ```sh
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    ```

    ![alt text](images/image-01.png)

- Search for all the charts for the installed repository. You should find one called **jetstack/cert-manager**
    ```sh
    helm search repo jetstack
    ```

    ![alt text](images/image-02.png)

- Download the values file to configure the helm chart.
    ```sh
    cd ~/Documents/MyHomelab-k8s/03-CERTMANAGER-LETS-ENCRYPT/
    helm show values jetstack/cert-manager > 01-cert-manager-values.yaml
    ``` 

- Then open this file in a editor, such as vim or Visual Studio code, and modify the following entries in the configuration.

    - `installCRDs: true` (So, it will install the CRDs for us)

        <img src="images/image-03.png" alt="drawing" width="750"/>

    - `namespace: cert-manager`

        <img src="images/image-04.png" alt="drawing" width="750"/>

    - `webhook.securePort: 10260`
    - `webhook.hostNetwork: true`

        <img src="images/image-07.png" alt="drawing" width="750"/>


> ⚠️ **Warning**: 
> 
> If you are on EKS and you are using a custom CNI such as Weave or Calico, the Kubernetes API server (which is in its own node) might not be able to reach the webhook pod. 
> 
> This happens because the control plane cannot be configured to run on a custom CNI on EKS, meaning that the CNIs cannot enable connectivity between the API server and the pods running in the worker nodes.
>
> By setting securePort to 10260 instead of relying on the default value (which is 10250), you will prevent a conflict between the webhook and the kubelet. 
>
> [The Definitive Debugging Guide for the cert-manager Webhook Pod](https://cert-manager.io/docs/troubleshooting/webhook/#cause-2-eks-on-a-custom-cni)


## Install the Certificate Manager Helm chart

- Create a new namespace called cert-manager, using this file [00-cert-manager-namespace.yaml](00-cert-manager-namespace.yaml).

    ```sh
    kubectl apply -f 00-cert-manager-namespace.yaml
    kubectl get ns
    ```

    ![alt text](images/image-05.png)

- Deploy the certificate Manager helm chart, using this file [01-cert-manager-values.yaml](01-cert-manager-values.yaml)

    ```sh
    helm install cert-manager jetstack/cert-manager --namespace cert-manager -f 01-cert-manager-values.yaml 
    watch kubectl get all -n cert-manager
    ```
    ![alt text](images/image-06.png)

    If the installation fails, use this command to uninstall the helm, make sure all the resources have been removed and try again.

    ```sh
    helm uninstall cert-manager -n cert-manager
    watch kubectl get all -n cert-manager
    ```

## Deploy of the Cluster Issuers

An Issuer is a namespaced resource, and it is not possible to issue certificates from an Issuer in a different namespace. This means you will need to create an Issuer in each namespace you wish to obtain Certificates in.

If you want to create a single Issuer that can be consumed in multiple namespaces, you should consider creating a ClusterIssuer resource. This is almost identical to the Issuer resource, however is non-namespaced so it can be used to issue Certificates across all namespaces.

> The Cluster Issuer will create a Secret defined as `privateKeySecretRef`. The Secret will be used to store the account's private key.
> 
> Select `name: letsencrypt-staging`, as if the production environment is abused, your IP address may be banned after several failed attempts.

- Create a **Staging ClusterIssuer**, using this file [02-cluster-issuer-letsencrypt-staging.yaml](02-cluster-issuer-letsencrypt-staging.yaml)

    Additonally, create a **Production ClusterIssuer**, using this file [03-cluster-issuer-letsencrypt-prod.yaml](03-cluster-issuer-letsencrypt-prod.yaml)

    > ⚠️ **Warning**: 
    >
    > You should replace this email address with your own.
    >
    > Let's Encrypt will use this to contact you about expiring certificates, and issues related to your account.

    ```sh
    code 02-cluster-issuer-letsencrypt-staging.yaml 
    # Replace the email address with your own.
    kubectl apply -f 02-cluster-issuer-letsencrypt-staging.yaml 

    code 03-cluster-issuer-letsencrypt-prod.yaml
    # Replace the email address with your own.
    kubectl apply -f 03-cluster-issuer-letsencrypt-prod.yaml
    ```
    <img src="images/image-08.png" alt="drawing" width="700"/>

- Confirm the Secrets and ClusterIssuers have been created.
    ```sh
    kubectl get secret -n cert-manager
    kubectl get ClusterIssuer -n cert-manager
    ```
    <img src="images/image-16.png" alt="drawing" width="700"/>


## Testing the certificate manager with TLS encrypted connection

- Create a namespace called test-web
    ```sh
    kubectl create ns test-web
    kubectl get ns
    ```
    <img src="images/image-11.png" alt="drawing" width="550"/>

- Create a new nginx deployment, using this file [test-a-deployment.yaml](test-a-deployment.yaml)
    ```sh
    kubectl apply -f test-a-deployment.yaml
    watch kubectl get all -n test-web
    ```

- Expose the deployment as a **service** on port 80.
    ```sh
    kubectl expose deploy nginx-deploy-main -n test-web --port 80
    watch kubectl get all -n test-web
    ```
    <img src="images/image-09.png" alt="drawing" width="750"/>

- Create a new ingress resource using this file [test-b-ingress.yaml](test-b-ingress.yaml).

    > Note: This time, the ingress have a provider issuer, a host name 'testing-cert.com' and it will create two secrets named `test-letsencrypt-staging-secret`.

    ```sh
    kubectl apply -f test-b-ingress.yaml
    kubectl get ingress -n test-web
    kubectl get secrets -n test-web
    kubectl describe secret test-letsencrypt-staging-secret -n test-web
    ```
    <img src="images/image-14.png" alt="drawing" width="900"/>
    <img src="images/image-17.png" alt="drawing" width="900"/>

- Create a new certificate using this file [test-c-certificate.yaml](test-c-certificate.yaml)
    ```sh
    kubectl apply -f test-c-certificate.yaml
    kubectl get certificate -n test-web
    kubectl describe certificate test-letsencrypt-staging-secret -n test-web
    kubectl get certificaterequest -n test-web
    kubectl describe certificaterequest test-letsencrypt-staging-secret-1 -n test-web
    ```
    <img src="images/image-18.png" alt="drawing" width="1200"/>

    > Note:
    >
    > The certificate request is not responded by Let's Encrypt staging, as you need an "A record" specified on your domain provider.

- Modify the `/etc/hosts`. Enter the record based on the ip address provided by the ingress controller.
    ```sh
    sudo vi /etc/hosts
    ```
    <img src="images/image-12.png" alt="drawing" width="750"/>

- Confirm the nginx server can be reached inside your network. Using the external IP address assigned, open this URL from your browser. [https://testing-cert.com/](https://testing-cert.com/)

    > Note: The browser will show the connection is not secure, but it will show a signed certificate.
    >
    > The certificate request is not responded by Let's encrypt staging, as you need a A record in your domain provider. 

    <img src="images/image-13.png" alt="drawing" width="7 50"/>

    <img src="images/image-15.png" alt="drawing" width="750"/>

- Make sure to delete all the test certificates

    ```sh
    kubectl delete certificates.cert-manager.io test-letsencrypt-staging-secret -n test-web
    kubectl delete -f test-c-certificate.yaml -n test-web
    kubectl delete -f test-b-ingress.yaml -n test-web
    kubectl delete svc nginx-deploy-main -n test-web
    kubectl delete -f test-a-deployment.yaml -n test-web
    kubectl delete ns test-web
    ```

- Make sure all secrets and services for test-web namespace have been deleted

    ```sh
    kubectl get svc -A
    kubectl get secrets -A
    ```
- Remove the entry in the `/etc/hosts` file