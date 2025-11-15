# OSS - NGINX Gateway Fabric

NGINX Gateway Fabric is used to manage ingress traffic routing for applications deployed on the cluster.
It uses Gateway API to manage ingress traffic routing for applications deployed on the cluster.

Because [Ingress NGINX will be deprecated after 2026](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/), this is the new recommended standard.

This configuration is deployed via Argo CD ApplicationSet.

## Domains Supported

- `api.tinyclover.com`
- `llm.tinyclover.com`

These domains are managed by ExternalDNS with AWS Route 53 integration.
