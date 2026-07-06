#!/bin/bash
# ============================================================
# generate-policies.sh
# Generates all NetworkPolicy yaml files for AKS storage chaos testing
# Usage: ./scripts/generate-policies.sh
# ============================================================

set -e

NAMESPACE="<your-namespace>"
SERVICES="service-a service-b service-e service-c service-d"
E2_IP="<region1-storage-pe-ip>"
C1_IP="<region2-storage-pe-ip>"
OUTPUT_DIR="k8s/network-policies"

mkdir -p $OUTPUT_DIR

echo "🔧 Generating NetworkPolicy files..."
echo ""

for svc in $SERVICES; do
  # E2 Storage Block
  cat > ${OUTPUT_DIR}/e2-storage-block-${svc}.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: e2-storage-block-${svc}
  namespace: ${NAMESPACE}
spec:
  podSelector:
    matchLabels:
      app: ${svc}
  policyTypes:
    - Egress
  egress:
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
              - ${E2_IP}/32
EOF
  echo "✅ e2-storage-block-${svc}.yaml"

  # C1 Storage Block
  cat > ${OUTPUT_DIR}/c1-storage-block-${svc}.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: c1-storage-block-${svc}
  namespace: ${NAMESPACE}
spec:
  podSelector:
    matchLabels:
      app: ${svc}
  policyTypes:
    - Egress
  egress:
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
              - ${C1_IP}/32
EOF
  echo "✅ c1-storage-block-${svc}.yaml"
done

echo ""
echo "✅ Generated $(ls ${OUTPUT_DIR}/*.yaml | wc -l) policy files in ${OUTPUT_DIR}/"
