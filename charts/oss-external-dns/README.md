# OSS - ExternalDNS

ExternalDNS automatically manages DNS records for Kubernetes resources with the 3rd party DNS provider.
In this project, we will use AWS Route 53.

This configuration is deployed via Argo CD ApplicationSet.
Currently, it is deployed on the cloud cluster, but it can be deployed on any other environment.

## Configuration

- **Provider**: AWS Route 53
- **Sources**: HTTPRoute resources
- **Policy**: sync (automatic DNS record management)
- **CNAME Preference** (`--aws-prefer-cname`): Uses CNAME records when possible for better performance.
- **TXT Record Prefix** (`--txt-prefix`): Required whenever CNAME preference is enabled — a TXT record cannot share the same name as a CNAME record, so ExternalDNS needs a prefix to place its ownership TXT record alongside the CNAME.
  - The prefix must also **differ per cluster**. ExternalDNS uses TXT records to decide what it owns, so a shared prefix causes one cluster to delete records managed by another.

## Domains Supported

- `haulrest.me`
- `tinyclover.com`

## How to use

ExternalDNS reads hostnames directly from the `spec.hostnames` field of an HTTPRoute — no annotation is required.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: some-domain-httproute
spec:
  hostnames:
    - some-domain.haulrest.me
```

For provider-specific behavior (e.g. Route 53 weighted routing), add annotations on the HTTPRoute:

```yaml
metadata:
  annotations:
    external-dns.alpha.kubernetes.io/set-identifier: "some-cluster"
    external-dns.alpha.kubernetes.io/aws-weight: "100"
```

## References

- [ExternalDNS GitHub](https://github.com/kubernetes-sigs/external-dns)
- [AWS Route 53 provider guide](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md)
- [Helm chart](https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns)
