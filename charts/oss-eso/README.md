# OSS - ESO (External Secrets Operator)

ESO is a Kubernetes operator for managing external secrets.
In this project, we will integrate ESO with GitLab Variables.

ESO will be set up with ApplicationSet, because we need to set up ESO for every cluster where you want to use ESO.
We will also set up a ClusterSecretStore for GitLab, see `charts/app-clustersecrets` folder for more details.

## Why ESO

Chosen over the main alternatives:

- **[Vault](https://developer.hashicorp.com/vault) + [argocd-vault-plugin](https://github.com/argoproj-labs/argocd-vault-plugin):** Makes Argo CD the secret owner, which [Argo CD's docs discourage](https://argo-cd.readthedocs.io/en/stable/operator-manual/secret-management/). Vault itself also has a non-trivial setup curve.
- **[Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets):** Simple to start with, but you have to manage the encryption key yourself. ESO delegates that to the external provider.
- **ESO:** Low setup overhead, `ExternalSecret` resources are safe to commit (reference-only), and the actual secret material stays in the provider.

## Configuration

We will use the default `values.yaml` file.

## References

- [Official Guide](https://external-secrets.io/latest/)
- [Helm chart](https://github.com/external-secrets/external-secrets/tree/main/deploy/charts/external-secrets)
