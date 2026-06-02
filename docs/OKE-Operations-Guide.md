# OKE Operations Guide

Notes for operating an OKE Basic cluster with an Always Free A1 Flex node pool.

## Confirmed Facts

- Replacing the boot volume is an Enhanced cluster feature, so it is not available on the Basic cluster.
- Replacing a node must be done cautiously because it can fail when A1 Flex capacity is unavailable.
- Updating the Kubernetes version and image settings on a node pool does not immediately upgrade existing worker nodes. The updated settings apply to worker nodes created after the change.

## Restrictions And Cautions

- Do not replace nodes, cycle nodes, replace boot volumes, or delete nodes when only one A1 Flex node is available.
- Do not proceed with a worker node upgrade if A1 Flex capacity is uncertain.
- Do not repeatedly create additional node pools. Failed node pools accumulate in the console, and they do not help when capacity is unavailable.

## Safe Upgrade Procedure

1. Upgrade the control plane first.
2. Update the node pool. The image and Kubernetes version must be compatible.
3. Temporarily secure at least one more node than the normal operating baseline.
   - If the extra node cannot be secured, do not proceed.
4. Replace the nodes.
5. Confirm that all nodes are `Ready` and running the same Kubernetes version.
6. Confirm that all pods are `Running` and all Deployments are `AVAILABLE`.
7. After the upgrade is complete, remove the temporary extra nodes and return the node pool to the normal operating size.
