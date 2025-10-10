# Backend Template

Austin Lee's standardized Helm chart template for backend services with dual-port support (API + MCP).

## Features

- **Dual Port Support**: API port for external access and MCP port for internal communication
- **ExternalSecret Integration**: Optional external secret management with GitLab Variables
- **Standard Kubernetes Resources**: Deployment, Service, Ingress, HPA and so on (made by `helm create`)

## Architecture

### Port Configuration

- **API Port**: Exposed via Ingress for external traffic, managed by ExternalDNS
- **MCP Port**: Internal cluster communication only, accessible via port-forwarding for testing

### External Secrets

- Uses GitLab Variables for secret management (ClusterSecretStore)
- Configurable data mapping from external secret store
- Enable/disable functionality via `externalSecret.enabled`

## Configuration

### Service Ports

```yaml
service:
  type: ClusterIP
  api:
    port: 80 # External API port
  mcp:
    enabled: false # Enable MCP port if you want to use it
    port: 3000 # Internal MCP port
```

### External Secrets

```yaml
externalSecret:
  enabled: false # Enable ExternalSecret creation if you want to use it
  data:
    - secretKey: "SOME_SECRET_TO_MAP"
      remoteRef:
        key: "SOME_SECRET_IN_GITLAB"
```

### Ingress

```yaml
ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: your-api.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
```

## Testing network ports

The API port is exposed via Ingress, so you can test it by accessing the Ingress URL.
The MCP port is not exposed via Ingress, so you need to port-forward to test it.

```bash
# Port forward to access MCP endpoint
kubectl port-forward svc/my-backend 3000:3000
curl http://localhost:3000
```

## Dependencies

- **External Secrets Operator**: Required for ExternalSecret functionality
- **ExternalDNS**: Required for automatic DNS route updates
- **GitLab ClusterSecretStore**: Required for secret management

## License

MIT License - Austin Lee
