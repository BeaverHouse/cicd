# Argo CD

[Argo CD](https://argo-cd.readthedocs.io/en/stable/) is a declarative, GitOps continuous delivery tool for Kubernetes.

This folder contains Argo CD OAuth secret, Project settings, and App-of-Apps configurations.  
This files are used in [My home-server install CLI](https://github.com/BeaverHouse/macos-oneclick-install) and not managed by Argo CD itself.

## Scaling References

Scaling of Argo CD itself can be important when you have a large number of applications to manage.  
Here are some references for scaling Argo CD.

- [Operator Manual - High Availability](https://argo-cd.readthedocs.io/en/stable/operator-manual/high_availability/)
- [Scalability Benchmarking Proposal](https://argo-cd.readthedocs.io/en/stable/proposals/004-scalability-benchmarking/)
- [Argo CD Architectures 2025 - Codefresh](https://codefresh.io/learn/argo-cd/a-comprehensive-overview-of-argo-cd-architectures-2025/)

## Configuration References

- [Ingress Configuration](https://argo-cd.readthedocs.io/en/latest/operator-manual/ingress/) — context for `server.insecure` when TLS is terminated upstream (Gateway / Ingress)
- [RBAC policy.csv](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/#policy-csv-composition) — reference when extending `rbac.policy.csv`
- [Slack Notifications](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/slack/) — future consideration for deploy / sync alerts
- [Deploying ArgoCD with Terraform & Entra ID SSO — WareTec](https://www.waretec.at/deploying-argocd-with-terraform-entra-id-sso/) — alternative SSO provider (Entra ID / Azure AD) reference
