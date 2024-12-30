#!/bin/bash

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print section headers
print_header() {
    echo -e "\n=== $1 ===\n"
}

# Check prerequisites
print_header "Checking Prerequisites"
if ! command_exists kubectl; then
    echo "kubectl not found. Please install kubectl first."
    exit 1
fi

# Check MetalLB namespace
print_header "Checking MetalLB Namespace"
if kubectl get namespace metallb-system >/dev/null 2>&1; then
    echo "✓ metallb-system namespace exists"
else
    echo "✗ metallb-system namespace not found"
    exit 1
fi

# Check webhook pods
print_header "Checking Webhook Pods"
kubectl get pods -n metallb-system -l component=webhook -o wide

# Check webhook service
print_header "Checking Webhook Service"
kubectl get svc -n metallb-system metallb-webhook-service

# Check webhook endpoints
print_header "Checking Webhook Endpoints"
kubectl get endpoints -n metallb-system metallb-webhook-service

# Check ValidatingWebhookConfiguration
print_header "Checking ValidatingWebhookConfiguration"
kubectl get validatingwebhookconfigurations metallb-webhook-configuration -o yaml

# Check webhook pod logs
print_header "Checking Webhook Pod Logs"
#WEBHOOK_POD=$(kubectl get pods -n metallb-system -l component=webhook -o jsonpath='{.items[0].metadata.name}')
WEBHOOK_POD=$(kubectl get pods -n metallb-system -o jsonpath='{.items[0].metadata.name}')

if [ ! -z "$WEBHOOK_POD" ]; then
    kubectl logs -n metallb-system "$WEBHOOK_POD"
else
    echo "No webhook pod found"
fi

# Test webhook with sample IPAddressPool
print_header "Testing IPAddressPool Creation"
cat <<EOF | kubectl apply -f - 
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: test-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.10.0/24
EOF

# Check webhook TLS certificate
print_header "Checking Webhook Certificate"
kubectl get secret -n metallb-system metallb-webhook-certificate
