# OSS - Cert Manager

Cert Manager is a Kubernetes operator that automatically provisions, renews, and manages TLS certificates from various issuing sources.

This configuration is deployed via Argo CD ApplicationSet.
We use Route 53 for DNS validation. Please see [here](https://cert-manager.io/docs/configuration/acme/dns01/route53/).

## Configuration

We will use the default `values.yaml` file.
