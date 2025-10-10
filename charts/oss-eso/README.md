# OSS - ESO (External Secrets Operator)

ESO is a Kubernetes operator for managing external secrets.
In this project, we will integrate ESO with GitLab Variables.

ESO will be set up with ApplicationSet, because we need to set up ESO for every cluster where you want to use ESO.
We will also set up a ClusterSecretStore for GitLab, see `charts/app-clustersecrets` folder for more details.

## Configuration

We will use the default `values.yaml` file.

## References

- [Official Guide](https://external-secrets.io/latest/)
- [Helm chart](https://github.com/external-secrets/external-secrets/tree/main/deploy/charts/external-secrets)
