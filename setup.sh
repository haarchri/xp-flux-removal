#!/usr/bin/env bash
set -aeuo pipefail

echo "Running setup.sh"

kind create cluster --name=flux-removal
kubectx kind-flux-removal
kubectl create ns upbound-system

helm repo add upbound-stable https://charts.upbound.io/stable && helm repo update
helm install uxp --namespace upbound-system upbound-stable/universal-crossplane --devel --wait

echo "Waiting for all pods to come online..."
kubectl -n upbound-system wait --for=condition=Available deployment --all --timeout=5m

echo "Creating provider..."
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-nop
spec:
  package: xpkg.upbound.io/upbound/upjet-provider-template:v0.0.0-159.gf689969
EOF

echo "Creating cloud credential secret..."
kubectl -n upbound-system create secret generic provider-secret --from-literal=credentials="{\"username\": \"admin\"}" --dry-run=client -o yaml | kubectl apply -f -

echo "Waiting until provider is healthy..."
kubectl wait provider.pkg --all --for condition=Healthy --timeout 5m

echo "Waiting for all pods to come online..."
kubectl -n upbound-system wait --for=condition=Available deployment --all --timeout=5m

echo "Creating a default provider config..."
cat <<EOF | kubectl apply -f -
apiVersion: template.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      name: provider-secret
      namespace: upbound-system
      key: credentials
EOF

## test case-1 remove crds
kubectl apply -f apis/
kubectl apply -f examples/
sleep 30
kubectl get managed
kubectl delete crds testobjects.test.haarchri.io  xtestobjects.test.haarchri.io 
kubectl get managed

sleep 30
kubectl delete -f apis/

## test case-2 remove xrd
kubectl apply -f apis/
kubectl apply -f examples/
sleep 30
kubectl get managed
kubectl delete -f apis/definition.yaml
sleep 30
kubectl get managed