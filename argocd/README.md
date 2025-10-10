# Argo CD Applications & ApplicationSets

[Argo CD](https://argo-cd.readthedocs.io/en/stable/) is a declarative, GitOps continuous delivery tool for Kubernetes.

There are 2 folders:

- `argocd/applications`: Argo CD Applications, for single deployment
- `argocd/applicationsets`: Argo CD ApplicationSets, for multiple deployments in 2 or more environments

## Dependency

1. Base cluster (for operations)
   - Must install K8s >> NGINX Ingress Controller >> Argo CD
2. `oss-argocd-config`: Argo CD Project definition
3. `oss-eso`: Install [External Secrets Operator](https://external-secrets.io/)
   - This is used for centralized secret management.
4. `app-clustersecrets`: Basic, common secrets for cluster.
   - Includes `ClusterSecretStore` and `ClusterExternalSecret` resources.
   - `ClusterExternalSecret` is applied on namespaces with custom label.
5. Other Applications or ApplicationSets can be deployed!
