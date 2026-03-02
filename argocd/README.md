# Argo CD Applications & ApplicationSets

All deployments are managed declaratively through Argo CD using a combination of **Applications**, **ApplicationSets**, and the **App of Apps** pattern.

- **ApplicationSets** for multi-cluster deployments with environment-specific overrides
- **Applications** for single-cluster workloads
- **App of Apps** pattern to manage all Application/ApplicationSet resources from a single root

```
argocd/
  ├── applications/       ← Single-cluster Applications
  └── applicationsets/    ← Multi-cluster ApplicationSets
        ├── oss-*.yaml    ← Infrastructure components
        └── app-*.yaml    ← Application workloads
```

**NOTE that some of the core components in home server, including Argo CD, are installed via CLI.**  
Please refer to [macos-oneclick-install](https://github.com/BeaverHouse/macos-oneclick-install)

## Dependency Order

1. Base cluster setup on the home server. Please refer to [macos-oneclick-install](https://github.com/BeaverHouse/macos-oneclick-install) repository.
   - Install K8s >> MetalLB, NGINX Gateway Fabric and various components >> Argo CD
2. `oss-eso`: [External Secrets Operator](https://external-secrets.io/)
   - Centralized secret management via third-party secret manager
3. `app-clustersecrets`
   - Includes `ClusterSecretStore` and `ClusterExternalSecret` resources (GHCR pull secret)
   - GHCR pull secret is auto-created in namespaces with `custom-image` label
4. `oss-cert-manager`: TLS certificate automation
5. `oss-nginx-gateway`: Gateway API + NGINX Gateway Fabric
6. `oss-external-dns`: Automatic DNS management
7. Other Applications or ApplicationSets can be deployed
