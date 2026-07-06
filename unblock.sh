#!/bin/bash
# ============================================================
# unblock.sh
# Remove storage block NetworkPolicies
# Usage: ./scripts/unblock.sh [region] [service]
#   region:  e2 | c1 | all (default: all)
#   service: service-a | service-b | service-e | service-c | service-d | all (default: all)
#
# Examples:
#   ./scripts/unblock.sh                  # unblock all services, all regions
#   ./scripts/unblock.sh e2               # unblock all services from e2 storage
#   ./scripts/unblock.sh e2 service-a    # unblock only service-a from e2 storage
# ============================================================

set -e

NAMESPACE="<your-namespace>"
REGION="${1:-all}"
SERVICE="${2:-all}"

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

echo "🔓 Removing storage block policies..."
echo "   Region(s) : $REGIONS"
echo "   Service(s): $SERVICES"
echo ""

for region in $REGIONS; do
  for svc in $SERVICES; do
    kubectl delete networkpolicy ${region}-storage-block-${svc} \
      -n $NAMESPACE --ignore-not-found
    echo "✅ Unblocked: $svc → $region storage"
  done
done

echo ""
echo "📋 Remaining NetworkPolicies in $NAMESPACE:"
kubectl get networkpolicy -n $NAMESPACE
