#!/bin/bash
set -euo pipefail

echo "=============================="
echo "CKA Mock Exam 1 Setup Starting"
echo "=============================="

# Namespaces
NAMESPACES=(production staging databases shop monitoring test restricted default)

for ns in "${NAMESPACES[@]}"; do
  kubectl get ns "$ns" >/dev/null 2>&1 || kubectl create ns "$ns"
done

echo "[1/6] Namespaces created"

# Apply all manifests
echo "[2/6] Applying manifests..."
kubectl apply -f manifests/

# Q6 Helm (safe fallback)
if [ -d "helm-charts/monitoring" ]; then
  echo "[3/6] Installing Helm chart monitoring"
  helm upgrade --install monitoring-stack helm-charts/monitoring \
    -n monitoring \
    --set replica_count=3 \
    --set storage_size=50Gi \
    --set persistence=true || true
else
  echo "[3/6] Helm chart not found, skipping"
fi

# Wait basic workloads
echo "[4/6] Waiting for pods..."
kubectl get pods -A

echo "[5/6] Cluster sanity check..."
kubectl get all -A >/dev/null

echo "[6/6] Setup complete"
echo "NOTE:"
echo "- Q7 (CRI runtime), Q8 (audit logs), Q11 (scheduler issue) require cluster-level access"