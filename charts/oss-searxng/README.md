# OSS - SearXNG

[SearXNG](https://github.com/searxng/searxng) is cluster-internal metasearch backend for global/EN web search. Exposed only as ClusterIP — no Ingress/HTTPRoute.

> [!NOTE]
> Domestic search (KR) uses NAVER Search API.

## License (AGPL-3.0) — no issue here

SearXNG is AGPL-3.0, but this deployment is compliant and the copyleft does **not** extend to our code:

- We run the **official `searxng/searxng` image unmodified** (no fork, no patched build).
- It is a **private, cluster-internal HTTP backend**
  - It's called via the network (`GET /search?format=json`). Talking to an AGPL program over its API does not make the caller a derivative work.
- AGPL §13 (network source-offer) would only trigger if we **modified** SearXNG **and** exposed that instance to external users — we do neither.

## Layout

Layout follows the standard Helm layout with minimal configurations.  
Added variant from normal deployment/service is below:

- ConfigMap for `settings.yml` (limiter off, image_proxy off, JSON format on)
- Init container for `secret_key` generation
  - `secret_key` is randomized per pod by the init container (never committed; not in the ConfigMap).
    This is OK because the caller (Tiny Clover) requests search via stateless JSON API — no stable session secret is needed.
  - If this ever scales to >1 replica and needs a shared key (or shared limiter/cache via Redis),
    switch to an ESO-backed Secret.

## Wiring from external pod

Set env: `SEARXNG_BASE_URL=http://searxng.searxng.svc.cluster.local:8080`

Smoke test from inside the cluster:

```bash
curl "http://searxng.searxng.svc.cluster.local:8080/search?q=hello&format=json&language=en"
```

`format=json` returning 200 with results = OK.
