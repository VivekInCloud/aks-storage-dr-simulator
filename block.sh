#!/bin/bash
# ============================================================
# block.sh
# Manually apply storage block NetworkPolicies
# Usage: ./scripts/block.sh [region] [service]
#   region:  e2 | c1 | all (default: all)
#   service: service-a | service-b | service-e | service-c | service-d | all (default: all)
#
# Examples:
#   ./scripts/block.sh                    # block all services, all regions
#   ./scripts/block.sh e2                 # block all services from e2 storage
#   ./scripts/block.sh e2 service-a      # block only service-a from e2 storage
# ============================================================

set -e

NAMESPACE="<your-namespace>"
REGION="${1:-all}"
SERVICE="${2:-all}"
POLICY_DIR="k8s/network-policies"

if [ "$REGION" = "all" ]; then
  REGIONS="e2 c1"
else
  REGIONS="$REGION"
fi

if [ "$SERVICE" = "all" ]; then
  SERVICES="service-a service-b service-e service-c service-d"
else
  SERVICES="$SERVICE"
fi

echo "🔒 Applying storage block policies..."
echo "   Region(s) : $REGIONS"
echo "   Service(s): $SERVICES"
echo ""

for region in $REGIONS; do
  for svc in $SERVICES; do
    FILE="${POLICY_DIR}/${region}-storage-block-${svc}.yaml"
    if [ -f "$FILE" ]; then
      kubectl apply -f $FILE
      echo "✅ Blocked: $svc → $region storage"
    else
      echo "⚠️  File not found: $FILE — run scripts/generate-policies.sh first"
    fi
  done
done

echo ""
echo "📋 Active NetworkPolicies in $NAMESPACE:"
kubectl get networkpolicy -n $NAMESPACE
