# Test creating an Ingress Route using Traefik with valid TLS certificates

Documentation:

- [Traefik & Kubernetes](https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/)


## File's replacement summary

- [test-b-nginx-certificate-prod.yaml](test-b-nginx-certificate-prod.yaml)
    - Replace `<your_domain>`

- [test-c-nginx-ingressroute-staging.yaml](test-c-nginx-ingressroute-staging.yaml)
    - Replace `<your_domain>`


## Create a Canonical Name DNS record in Cloudflare for your Ingress Route

- Login to CloudFlare, create a CNAME (Canonical Name) DNS record to point to the previously created A record `homelab-traefik.<your_domain>`

    <img src="images/image-01.png" alt="drawing" width="1100"/>

- Create a new deployment using this template [test-a-nginx-deployment.yaml](test-a-nginx-deployment.yaml)

    ```sh
    kubectl apply -f test-a-nginx-deployment.yaml
    ```

- Create a new **Production**  certificate, using the Cluster Issuer previously created `dns-challenge-acme-prod`. Use this file [test-b-nginx-certificate-prod.yaml](test-b-nginx-certificate-prod.yaml), which will create a secret named `nginx-test-cluster-cert-prod-tls`.

    > ⚠️ **Warning**: 
    >
    > - You should replace this domain with your own.
    >
    > - The namespace the Certificate should be created in the same place as the IngressRoute

    ```sh
    kubectl apply -f test-b-nginx-certificate-prod.yaml

    watch kubectl describe certificates nginx-test-cluster-cert-prod -n test-web

    kubectl get secret nginx-test-cluster-cert-prod-tls -n test-web -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text
    ```

    <img src="images/image-02.png" alt="drawing" width="900"/>

- Create a Service and Ingress Route using this file [test-c-nginx-ingressroute-prod.yaml](test-c-nginx-ingressroute-prod.yaml). 

    The service `nginx-deploy-main` won't have an external ip assigned. 
    
    The Ingress Route will use the secretName `nginx-test-cluster-cert-prod-tls`.

    > Note:
    >
    > The namespace the Certificate should be created in the same place as the IngressRoute

    ```sh
    kubectl apply -f test-c-nginx-ingressroute.yaml
    ```

    <img src="images/image-03.png" alt="drawing" width="1100"/>


- Then open a browser and navigate to [https://nginx.<your_domain>/](https://nginx.<your_domain>/). Inspect the certificate and confirm it's valid.

    <img src="images/image-04.png" alt="drawing" width="900"/>

- You can delete the test objects

    ```sh
    kubectl delete -f test-c-nginx-ingressroute-prod.yaml 
    kubectl delete -f test-b-nginx-certificate-prod.yaml 
    kubectl delete -f test-a-nginx-deployment.yaml 
    kubectl delete ns test-web 
    ```


