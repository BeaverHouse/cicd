# App - Cluster Secrets

This chart is used to store secrets in the cluster.

## Prerequisites

- You need to install the ESO (External Secrets Operator) first.
- You need to create the `gitlab-eso-secret` secret in the `external-secrets` namespace.
  It needs to be secure, so I worked directly with the secret.
