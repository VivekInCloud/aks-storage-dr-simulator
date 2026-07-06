# AKS Storage DR Testing — Network Policy Based DR Simulation

Simulate Azure Storage regional failures in AKS using Kubernetes NetworkPolicy. Block private endpoint traffic at the pod level to test GRS failover behavior — without any infrastructure changes.

---

## Architecture

```
AKS Pod (app=service-a)
  │
  ▼  Egress blocked by NetworkPolicy
<region1-storage-pe-ip>:443  ← Region1 Storage Private Endpoint
<region2-storage-pe-ip>:443   ← Region2 Storage Private Endpoint
  │
  ▼
Azure Storage Account (GRS)
```

---


## Storage Endpoints

| Region | Storage Account | Private Endpoint IP |
|--------|----------------|-------------------|
| East US 2 | `your-storageaccount-e2` | `<region1-storage-pe-ip>` |
| Central US | `your-storageaccount-c1` | `<region2-storage-pe-ip>` |

---

## GitHub Actions (Recommended)

Go to **Actions → AKS Storage Chaos Test → Run workflow**

| Input | Options |
|-------|---------|
| Action | `block` / `unblock` |
| Region | `all` / `r1` / `r2` |
| Services | `all` / `service-a` / `service-b` / `service-e` / `service-c` / `service-d` |

### Required Secrets

| Secret | Description |
|--------|-------------|
| `NONPRD_AUT_ARM_CLIENT_ID_SPN` | Service Principal Client ID |
| `NONPRD_AUT_ARM_SECRET_SPN` | Service Principal Secret |
| `NONPRD_MGT_SUB_ID` | Azure Subscription ID |
| `ARM_TENANT_ID` | Azure Tenant ID |

---

## Manual Usage

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Block all services from E2 storage
./scripts/block.sh e2

# Block specific service from specific region
./scripts/block.sh e2 service-a

# Verify connectivity from all pods
./scripts/verify.sh

# Unblock everything
./scripts/unblock.sh

# Unblock specific service
./scripts/unblock.sh e2 service-a
```

---

## Verify the Block is Working

```bash
# Should timeout when blocked (not return HTTP error)
kubectl exec -it <pod> -n <your-namespace> -- \
  nc -zv -w 5 <region1-storage-pe-ip> 443

# ✅ Blocked:   Connection timed out
# ❌ Not blocked: Connection succeeded
```

---

## Cleanup

```bash
# Remove all NetworkPolicies
./scripts/unblock.sh

# Or via kubectl directly
kubectl delete networkpolicy \
  storage-block-service-a \
---

## Prerequisites

- AKS cluster with Network Policy enabled (`azure` or `calico`)
- `kubectl` configured with cluster admin credentials
- `nc` (netcat) available in target containers for connectivity testing

---

## Author

**Vivek Thirumoorthy** — Senior Technical Architect · CloudOps Lead  
[linkedin.com/in/VivekInCloud](https://linkedin.com/in/VivekInCloud)
