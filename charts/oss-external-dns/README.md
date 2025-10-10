# OSS - ExternalDNS

ExternalDNS automatically manages DNS records for Kubernetes resources with the 3rd party DNS provider.
In this project, we will use AWS Route 53.

This configuration is deployed via Argo CD ApplicationSet.
Currently, it is deployed on the cloud cluster, but it can be deployed on any other environment.

## Configuration

- **Provider**: AWS Route 53
- **Sources**: Ingress resources
- **Policy**: sync (automatic DNS record management)
- **CNAME Preference**: Uses CNAME records when possible for better performance
- **TXT Record Prefix**: Differs by cluster
  - You need to set the diffrernt prefix for each cluster.
    Otherwise, it will conflict with other clusters and make unintended changes.

## Domains Supported

- `haulrest.me`
- `tinyclover.com`

## How to use

Add the following annotation to the ingress resource.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: some-domain-ingress
  annotations:
    external-dns.alpha.kubernetes.io/hostname: some-domain.haulrest.me
```
