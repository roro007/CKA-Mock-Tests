#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "================================================"
echo "       CKA Mock Exam 01 Environment Setup"
echo "================================================"

echo
echo "Cluster:"
kubectl cluster-info

echo
echo "-----------------------------------------------"
echo "Step 1: Creating namespaces"
echo "-----------------------------------------------"

kubectl apply -f "${ROOT_DIR}/manifests/namespaces.yaml"


echo
echo "-----------------------------------------------"
echo "Step 2: Applying Question starting states"
echo "-----------------------------------------------"


apply_if_exists()
{
    if [ -d "$1" ]; then
        echo "Applying $1"
        kubectl apply -f "$1"
    elif [ -f "$1" ]; then
        echo "Applying $1"
        kubectl apply -f "$1"
    else
        echo "Skipping $1 (not found)"
    fi
}


# Q1 - Pod troubleshooting
apply_if_exists "${ROOT_DIR}/q01"


# Q2 - RBAC starting state
apply_if_exists "${ROOT_DIR}/q02"


# Q3 - Node maintenance
apply_if_exists "${ROOT_DIR}/q03"


# Q4 - Persistent volume scenario
apply_if_exists "${ROOT_DIR}/q04"


# Q5 - Network policy scenario
apply_if_exists "${ROOT_DIR}/q05"


# Q6 Helm handled separately
echo
echo "Q06 Helm chart will be installed separately"


# Q7
echo
echo "Q07 skipped:"
echo "CRI-dockerd requires node OS configuration"


# Q8
echo
echo "Q08 skipped:"
echo "API Server audit logging requires control-plane configuration"


# Q9 - HPA scenario
apply_if_exists "${ROOT_DIR}/q09"


# Q10 - Ingress scenario
apply_if_exists "${ROOT_DIR}/q10"


# Q11
echo
echo "Q11 skipped:"
echo "Scheduler troubleshooting requires control-plane access"


# Q12
apply_if_exists "${ROOT_DIR}/q12"


# Q13
apply_if_exists "${ROOT_DIR}/q13"


# Q14
apply_if_exists "${ROOT_DIR}/q14"


# Q15
apply_if_exists "${ROOT_DIR}/q15"



echo
echo "-----------------------------------------------"
echo "Step 3: Installing Q06 Helm chart"
echo "-----------------------------------------------"


kubectl create namespace monitoring \
--dry-run=client \
-o yaml | kubectl apply -f -


helm upgrade --install monitoring-stack \
"${ROOT_DIR}/helm-charts/monitoring" \
-n monitoring \
--set replica_count=3 \
--set persistence.enabled=true \
--set storage_size=50Gi



echo
echo "-----------------------------------------------"
echo "Step 4: Waiting for workloads"
echo "-----------------------------------------------"


kubectl wait \
--for=condition=Available \
deployments \
-A \
--timeout=180s || true


echo
echo "-----------------------------------------------"
echo "Environment Summary"
echo "-----------------------------------------------"


echo
echo "Namespaces:"
kubectl get ns


echo
echo "Deployments:"
kubectl get deployments -A


echo
echo "Pods:"
kubectl get pods -A


echo
echo "================================================"
echo " CKAD/CKA Mock Exam 01 Environment Ready"
echo "================================================"

echo
echo "Manual questions requiring node/control-plane:"
echo " - Q07 CRI-dockerd"
echo " - Q08 API Server Audit Logs"
echo " - Q11 kube-scheduler troubleshooting"
