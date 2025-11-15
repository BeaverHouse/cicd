# NGINX Ingress → Gateway API 마이그레이션 계획

NGINX Ingress는 2026년 3월 기준으로 Deprecate됩니다.  
이에 따라 Gateway API로 전환하기 위한 계획입니다.

여기서는 NGINX Gateway Fabric을 사용하며, NGINX Ingress와 병행 운영하면서 DNS 가중치 기반 점진적 전환을 진행합니다.

---

## 현재 구조

```
argocd/applicationsets/
├── oss-ingress-nginx.yaml     # ← 교체 대상
├── oss-cert-manager.yaml      # Gateway API 지원 필요
├── oss-external-dns.yaml      # Gateway API 지원 필요
└── app-tiny-clover.yaml       # Ingress → HTTPRoute 전환

charts/
├── oss-ingress-nginx/         # ← 제거 예정
├── templates/backend-go/      # ← HTTPRoute, ClientSettingsPolicy 추가
└── app-tiny-clover/           # ← Gateway 추가
    └── values/oke.yaml        # 7개 서비스
```

**서비스:** ae-analyzer, ba-analyzer, file-manager, llm-client, data-aggregator, life-organizer, service-api
**도메인:** api.tinyclover.com, llm.tinyclover.com

---

## Gateway API 개요 (2025)

**주요 기능:**

- HTTPRoute, GRPCRoute (GA)
- Gateway, GatewayClass (GA)
- Backend policies, CEL validation
- cert-manager, external-dns 네이티브 지원

**NGINX Gateway Fabric:**

- 공식 Gateway API 구현체 (GA)
- Helm chart: `oci://ghcr.io/nginx/charts/nginx-gateway-fabric`

---

## Phase 1: 준비

### 1.1 NGINX Gateway Fabric ApplicationSet 생성

**argocd/applicationsets/oss-nginx-gateway.yaml**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: oss-nginx-gateway-applicationset
spec:
  goTemplate: true
  generators:
    - list:
        elements:
          - name: oke
            project: cloud
            cluster: oke
  template:
    metadata:
      name: "oss-nginx-gateway-{{ .name }}"
    spec:
      project: "{{ .project }}"
      sources:
        - repoURL: oci://ghcr.io/nginx/charts
          targetRevision: 2.2.1
          chart: nginx-gateway-fabric
          helm:
            releaseName: nginx-gateway
            valueFiles:
              - $customRepo/charts/oss-nginx-gateway/values.yaml
        - repoURL: https://github.com/BeaverHouse/cicd.git
          targetRevision: main
          ref: customRepo
      destination:
        name: "{{ .cluster }}"
        namespace: nginx-gateway
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
```

**charts/oss-nginx-gateway/values.yaml**

```yaml
# NGINX control plane 설정
nginx:
  kind: daemonSet # deployment 또는 daemonSet
  service:
    type: LoadBalancer
    externalTrafficPolicy: Local
    annotations:
      # Oracle Cloud Load Balancer 설정
      service.beta.kubernetes.io/oci-load-balancer-shape: flexible
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-min: "10"
      service.beta.kubernetes.io/oci-load-balancer-shape-flex-max: "100"
```

### 1.2 cert-manager 업데이트

version: v1.19.1

**charts/oss-cert-manager/values.yaml**

```yaml
config:
  apiVersion: controller.config.cert-manager.io/v1alpha1
  kind: ControllerConfiguration
  enableGatewayAPI: true
```

### 1.3 external-dns 업데이트

version: 1.19.0

**charts/oss-external-dns/values/values-cloud.yaml, charts/oss-external-dns/values/values-oke.yaml**

```yaml
external-dns:
  sources:
    - ingress
    - gateway-httproute # 추가
```

### 1.4 Gateway 리소스

아래 링크를 참고하여 작성합니다.  
https://cert-manager.io/docs/usage/gateway/

**charts/app-tiny-clover/templates/gateway.yaml** : Gateway 리소스이며, 1번만 정의됩니다.

```yaml
{{- if .Values.gateway.enabled }}
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: api-gateway
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-cluster-issuer
spec:
  gatewayClassName: nginx
  listeners:
    - name: https-api
      protocol: HTTPS
      port: 443
      hostname: api.tinyclover.com
      tls:
        mode: Terminate
        certificateRefs:
          - name: api-tinyclover-tls
    - name: https-llm
      protocol: HTTPS
      port: 443
      hostname: llm.tinyclover.com
      tls:
        mode: Terminate
        certificateRefs:
          - name: llm-tinyclover-tls
{{- end }}
```

### 1.5 HTTPRoute 템플릿

아래 링크를 참고하여 작성합니다.  
https://gateway-api.sigs.k8s.io/api-types/httproute/

**templates/backend-go/templates/httproute.yaml** : 각 서비스별로 정의합니다.

```yaml
{{- if .Values.httproute.enabled }}
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ include "backend-go.fullname" . }}
  {{- with .Values.httproute.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  parentRefs:
    {{- toYaml .Values.httproute.parentRefs | nindent 4 }}
  hostnames:
    {{- toYaml .Values.httproute.hostnames | nindent 4 }}
  rules:
    {{- range .Values.httproute.rules }}
    - matches:
        - path:
            type: {{ .path.type | default "PathPrefix" }}
            value: {{ .path.value }}
      {{- with .timeouts }}
      timeouts:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      backendRefs:
        - name: {{ include "backend-go.fullname" $ }}
          port: {{ $.Values.service.api.port }}
    {{- end }}
{{- end }}
```

### 1.6 ClientSettingsPolicy 템플릿

아래 링크를 참고하여 작성합니다.  
https://docs.nginx.com/nginx-gateway-fabric/traffic-management/client-settings/

**templates/backend-go/templates/clientsettingspolicy.yaml** : 각 서비스별로 정의합니다.

```yaml
{{- if .Values.clientSettings.enabled }}
apiVersion: gateway.nginx.org/v1alpha1
kind: ClientSettingsPolicy
metadata:
  name: {{ include "backend-go.fullname" . }}-client
spec:
  targetRefs:
    - kind: HTTPRoute
      name: {{ include "backend-go.fullname" . }}
  body:
    maxSize: {{ .Values.clientSettings.body.maxSize }}
    timeout: {{ .Values.clientSettings.body.timeout }}
{{- end }}
```

### 1.7 Git Commit & ArgoCD Sync

이 때 Load Balancer가 생성됩니다. 즉, NGINX Ingress와 병행 운영되고 Load Balancer가 2개가 됩니다.

---

## Phase 2: PoC

ae-analyzer를 예시로 Gateway API를 적용합니다.

### 2.1. Gateway API 활성화 (Dual-stack)

먼저 Gateway 리소스를 활성화합니다.

```yaml
gateway:
  enabled: true
```

그 다음 AE Analyzer의 HTTPRoute와 ClientSettingsPolicy를 활성화합니다.

```yaml
ae-analyzer:
  # 기존 Ingress 유지
  ingress:
    enabled: true
    annotations:
      external-dns.alpha.kubernetes.io/aws-weight: "50"

  # HTTPRoute + ClientSettingsPolicy 추가
  httproute:
    enabled: true
    parentRefs:
      - name: api-gateway
        sectionName: https-api
    hostnames:
      - api.tinyclover.com
    annotations:
      external-dns.alpha.kubernetes.io/hostname: api.tinyclover.com
      external-dns.alpha.kubernetes.io/aws-weight: "50"
    rules:
      - path:
          type: PathPrefix
          value: /ae-analyzer/v1
        timeouts:
          request: 60s
          backendRequest: 60s
  clientSettings:
    enabled: true
    body:
      maxSize: 10m
      timeout: 60s
```

### 2.2 트래픽 점진적 전환

**1단계: 25% → 75%**

```yaml
ingress.annotations.aws-weight: "25"
httproute.annotations.aws-weight: "75"
```

**2단계: 0% → 100%**

```yaml
ingress.annotations.aws-weight: "0"
httproute.annotations.aws-weight: "100"
```

---

## Phase 3: Migration

남은 서비스들을 순차적으로 Gateway API로 마이그레이션합니다.

1. service-api
2. life-organizer
3. data-aggregator
4. **file-manager** (body size 100m)
5. **llm-client** (다른 도메인 llm.tinyclover.com)
6. ba-analyzer

주의사항

- BA Analyzer는 사용자가 많으므로 마지막에 천천히 전환합니다.
- File Manager는 파일을 처리하기 때문에 설정이 다릅니다.

  ```yaml
  file-manager:
    httproute:
      rules:
        - timeouts:
            request: 300s
            backendRequest: 300s
    clientSettings:
      body:
        maxSize: 100m
        timeout: 300s
  ```

---

## Phase 4: 정리

- Ingress 비활성화
- NGINX Ingress ApplicationSet 삭제
- Helm 템플릿에서 Ingress 관련 코드 제거

## Annotation 매핑

| NGINX Ingress                    | Gateway API                       |
| -------------------------------- | --------------------------------- |
| `cert-manager.io/cluster-issuer` | Gateway annotation                |
| `nginx.../proxy-body-size`       | ClientSettingsPolicy.body.maxSize |
| `nginx.../proxy-read-timeout`    | HTTPRoute.timeouts.request        |
| `nginx.../proxy-send-timeout`    | HTTPRoute.timeouts.backendRequest |
| `external-dns.../hostname`       | HTTPRoute annotation (동일)       |
| `external-dns.../aws-weight`     | HTTPRoute annotation (동일)       |

## 참고 자료

- [Gateway API Documents](https://gateway-api.sigs.k8s.io/)
- [NGINX Gateway Fabric](https://docs.nginx.com/nginx-gateway-fabric/)
- [Annotated Gateway resource - cert-manager](https://cert-manager.io/docs/usage/gateway/)
- [Gateway API Route Sources - external-dns](https://kubernetes-sigs.github.io/external-dns/latest/docs/sources/gateway-api/)
