# Backend Template

Austin Lee's standardized Helm chart template for backend services with dual-port support (API + MCP).

## Features

- **Dual Port Support**: API port for external access and MCP port for internal communication
- **ExternalSecret Integration**: Optional external secret management with GitLab Variables
- **Gateway API Support**: HTTPRoute for external routing with ExternalDNS integration
- **Standard Kubernetes Resources**: Deployment, Service, HPA and so on (made by `helm create`)

## Architecture

### Port Configuration

- **API Port**: Exposed via HTTPRoute for external traffic, managed by ExternalDNS
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

### HTTPRoute (Gateway API)

```yaml
httproute:
  enabled: false
  parentRefs:
    - name: your-gateway-name
      sectionName: https-listener-name
  hostnames:
    - your-api.example.com
  annotations:
    external-dns.alpha.kubernetes.io/hostname: your-api.example.com
    external-dns.alpha.kubernetes.io/set-identifier: "your-identifier"
  rules:
    - path:
        type: PathPrefix
        value: /
      timeouts:
        request: 60s
        backendRequest: 60s
```

### ClientSettings (NGINX Gateway Fabric)

```yaml
clientSettings:
  enabled: false
  body:
    maxSize: 10m
    timeout: 60s
```

## Testing network ports

The API port is exposed via HTTPRoute, so you can test it by accessing the configured hostname.
The MCP port is not exposed externally, so you need to port-forward to test it.

```bash
# Port forward to access MCP endpoint
kubectl port-forward svc/my-backend 3000:3000
curl http://localhost:3000
```

## Dependencies

- **Gateway API**: Required for HTTPRoute functionality
- **NGINX Gateway Fabric**: Gateway implementation with ClientSettings support
- **External Secrets Operator**: Required for ExternalSecret functionality
- **ExternalDNS**: Required for automatic DNS route updates
- **GitLab ClusterSecretStore**: Required for secret management

## License

MIT License - Austin Lee
