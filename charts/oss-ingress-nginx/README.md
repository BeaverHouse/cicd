# OSS - Ingress Nginx

NGINX Ingress Controller is used to manage ingress traffic routing for applications deployed on the cluster.

This configuration is deployed via Argo CD ApplicationSet.
Currently, it is deployed on the cloud cluster, but it can be deployed on any other environment.

## Configuration

- **Controller Type**: DaemonSet for high availability
- **HTTP**: Disabled for security (HTTPS only)
- **Traffic Policy**: Cluster-wide load balancing
- **Ports**: Standard HTTP (80) and HTTPS (443)

## Domains Supported

- `haulrest.me`
- `tinyclover.com`

Both domains are managed by ExternalDNS with AWS Route 53 integration.
