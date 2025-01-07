# Certificate for a Dynamic DNS Domain in Kubernetes through cert-manager

This guide will help you set up a certificate for a Dynamic DNS domain in your Kubernetes cluster using cert-manager.

YouTube video: [[09.02] Certificate for a dynamic DNS domain in Kubernetes through cert-manager](https://www.youtube.com/watch?v=KVoRYtLGTjY&list=PLVBNl4E-lnBJR9UwFd5w05ama_4IkV-8I&index=11)

## Prerequisites

- A dynamic DNS provider (e.g. Cloudflare).
- A Domain name that you own (e.g. NameCheap, Cloudflare, etc)
- A certificate Manager installed in your Kubernetes cluster (previous step).

## Adjust DNS records and create API Key in Cloudflare

- You must adjust DNS to Cloudflare nameserver by changing your DNS record point to Cloudflare. This example shows chaning NameCheap to point to Cloudflare.

    [How to set up DNS records for your domain in a Cloudflare account](https://www.namecheap.com/support/knowledgebase/article.aspx/9607/2210/how-to-set-up-dns-records-for-your-domain-in-a-cloudflare-account/)

    <img src="images/image-05.png" alt="drawing" width="1000"/>

- Create a Cloudflare API token for use in cert-manager. Create and verify the domain you want to create an SSL certificate. 

    Documentation: [Create Cert-manager ClustterIssuer with Cloudflare for Automate issue and renew](https://nolifelover.medium.com/create-cert-manager-clustterissuer-with-cloudflare-for-automate-issue-and-renew-lets-encrypt-ssl-4877d3f12b44)

    - Go to [Cloudflare dashboard](https://dash.cloudflare.com/) > [My Profile](https://dash.cloudflare.com/profile) (Right top corner) > API Tokens. 
    
        <img src="images/image-06.png" alt="drawing" width="1000"/>

    - Click Create Token button selecting the "Edit Zone DNS" option.

        <img src="images/image-07.png" alt="drawing" width="700"/>

    - Then, fill Permission section form below.

        <img src="images/image-08.png" alt="drawing" width="700"/>

    - Take note of the API Token generated.

        <img src="images/image-09.png" alt="drawing" width="700"/>


## Modify the configuration for the jetstack/cert-manager Helm Repository re-deploy

- Make a copy of the values file to configure the helm chart.

    ```sh
    cp ~/Documents/MyHomelab-k8s/04-CERTMANAGER/01-cert-manager-values.yaml ~/Documents/MyHomelab-k8s/05-DYNAMIC-DNS/01-cert-manager-values.yaml
    helm show values jetstack/cert-manager > 01-cert-manager-values.yaml
    ``` 

- To make changes to the existing `cert-manager` deployment, open this file in a editor, such as vim or Visual Studio code, and modify the following entries in the configuration.

    - `dns01RecursiveNameservers:` "8.8.8.8:53,1.1.1.1:53"

        <img src="images/image-02.png" alt="drawing" width="1000"/>

    > cert-manager will check the correct DNS records exist before attempting a DNS01 challenge. 
    >
    > By default cert-manager will use the recursive nameservers taken from /etc/resolv.conf to query for the authoritative nameservers, which it will then query directly to verify the DNS records exist.

- Upgrade the existing `cert-manager` deployment
    ```sh
    cd ~/Documents/MyHomelab-k8s/04-CERTMANAGER/
    helm upgrade cert-manager jetstack/cert-manager --namespace cert-manager -f 01-cert-manager-values.yaml
    ```
    <img src="images/image-03.png" alt="drawing" width="800"/>

- Confirm the deployment configuration has been updated correctly.
    ```sh
    kubectl describe deployment cert-manager -n cert-manager
    ```
    <img src="images/image-04.png" alt="drawing" width="800"/>


# Deploy a ClusterIssuer and a Certificate with Cloudflare DNS proof

Official Documentation: [Cert-Manager DNS01 for Cloudflare](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/)

> The Cluster Issuer will create a Secret named: `cluster-issuer-account-key`
>
> The API Token used to connect to CloudFlare will be named: `cloudflare-api-token`

- Create a **Secret** and a **ClusterIssuer**, using this file [02-cluster-issuer-cloudflare.yaml](02-cluster-issuer-cloudflare.yaml)

    > You should replace this email address with your own.
    >
    > You also need to enter your Cloudflare API Token

    ```sh
    code 02-cluster-issuer-cloudflare.yaml 
    # Replace the email address with your own.
    kubectl apply -f 02-cluster-issuer-cloudflare.yaml
    kubectl get clusterissuer -A -o wide
    kubectl get secrets -A -o wide
    ```
    <img src="images/image-11.png" alt="drawing" width="800"/>

    <img src="images/image-10.png" alt="drawing" width="800"/>


    > **Ready Status of the ClusterIssuer:**
    >
    > -	True: The ClusterIssuer is properly configured and ready to issue certificates.
    >
    > - False: There is an issue preventing the ClusterIssuer from functioning (e.g., misconfiguration, unreachable endpoint).
    > 
    > - Unknown: The status of readiness is unknown, possibly due to a lack of initialization.

- Before creating the certificate on CloudFlare, You have to create private DNS to the names mentioned in the manifest above like the following:

https://ruanbekker.hashnode.dev/cert-manager-dns-challenge-with-cloudflare-on-kubernetes#heading-cert-manager







- Request a certificate, using your domain, i.e. `example.dev` hosted in CloudFlare, creating a wildcard certificate on the sub-domain *.nginx.example.com.

    Certificates are scoped on a namespace level, and ClusterIssuer's are cluster-wide, therefore you can prefix your certificate with the namespace.

    Create the certificate using this file [03-certificate-cloudflare.yaml](03-certificate-cloudflare.yaml)

    > You should replace this name with your own DNS entry

    ```sh

    ```



