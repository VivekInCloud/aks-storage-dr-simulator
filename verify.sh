#!/bin/bash
# ============================================================
# verify.sh
# Test storage connectivity from all service pods
# Usage: ./scripts/verify.sh [region]
#   region: e2 | c1 | all (default: all)
#
# Examples:
#   ./scripts/verify.sh         # test all services against all regions
#   ./scripts/verify.sh e2      # test all services against e2 storage only
# ============================================================

NAMESPACE="<your-namespace>"
REGION="${1:-all}"
SERVICES="service-a service-b service-e service-c service-d"
E2_IP="<region1-storage-pe-ip>"
C1_IP="<region2-storage-pe-ip>"

if [ "$REGION" = "all" ]; then
  REGIONS="e2 c1"
else
  REGIONS="$REGION"
fi

echo "🔍 Testing storage connectivity..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-20s %-10s %-20s %s\n" "SERVICE" "REGION" "ENDPOINT IP" "STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for region in $REGIONS; do
  if [ "$region" = "e2" ]; then
    IP=$E2_IP
  else
    IP=$C1_IP
  fi

  for svc in $SERVICES; do
    POD=$(kubectl get pod -n $NAMESPACE -l app=${svc} \
      -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

    if [ -z "$POD" ]; then
      printf "%-20s %-10s %-20s %s\n" "$svc" "$region" "$IP" "⚠️  No pod found"
      continue
    fi

    RESULT=$(kubectl exec $POD -n $NAMESPACE -- \
      nc -zv -w 5 $IP 443 2>&1)

    if echo "$RESULT" | grep -q "succeeded\|open"; then
      printf "%-20s %-10s %-20s %s\n" "$svc" "$region" "$IP" "✅ Connected"
    else
      printf "%-20s %-10s %-20s %s\n" "$svc" "$region" "$IP" "🔒 Blocked"
    fi
  done
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Active NetworkPolicies in $NAMESPACE:"
kubectl get networkpolicy -n $NAMESPACE
