---
description: Kubernetes operations — deploy, debug, scale, secure. Use when working with k8s manifests, helm charts, kubectl debugging, ingress/service mesh config, or migrating workloads to/from k8s.
mode: agent
---

# Kubernetes Skill

Production k8s patterns. Defaults assume cloud-managed control plane (EKS/GKE/AKS). For self-hosted (k3s/kind), call out differences.

## Quick decisions

| Need | Pick |
|---|---|
| One-off batch job | Job (not Deployment) |
| Long-running service | Deployment + Service |
| Stateful workload | StatefulSet + headless Service + PVC |
| Per-node agent | DaemonSet |
| Recurring job | CronJob |
| Sidecar (logs/proxy) | Container in same pod |
| Init step (DB migration) | initContainers |

## Manifest skeleton (Deployment + Service + Ingress)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  labels: { app: api }
spec:
  replicas: 3
  strategy: { type: RollingUpdate, rollingUpdate: { maxUnavailable: 1, maxSurge: 1 } }
  selector: { matchLabels: { app: api } }
  template:
    metadata: { labels: { app: api } }
    spec:
      containers:
        - name: api
          image: registry.example.com/api:1.2.3
          ports: [{ containerPort: 8080 }]
          resources:
            requests: { cpu: 100m, memory: 128Mi }
            limits:   { cpu: 500m, memory: 512Mi }
          readinessProbe: { httpGet: { path: /health, port: 8080 }, periodSeconds: 5 }
          livenessProbe:  { httpGet: { path: /health, port: 8080 }, periodSeconds: 30, initialDelaySeconds: 30 }
          env:
            - name: DATABASE_URL
              valueFrom: { secretKeyRef: { name: api-secrets, key: database-url } }
---
apiVersion: v1
kind: Service
metadata: { name: api }
spec:
  selector: { app: api }
  ports: [{ port: 80, targetPort: 8080 }]
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
spec:
  ingressClassName: nginx
  rules:
    - host: api.example.com
      http: { paths: [{ path: /, pathType: Prefix, backend: { service: { name: api, port: { number: 80 } } } }] }
  tls: [{ hosts: [api.example.com], secretName: api-tls }]
```

## Debug pattern

```bash
kubectl get pods -n <ns> -l app=api -o wide        # see node + IP
kubectl describe pod <pod> -n <ns>                 # events, restarts, image-pull errors
kubectl logs <pod> -n <ns> --previous              # crashed pod's last logs
kubectl logs <pod> -n <ns> -c <container> -f       # stream specific container
kubectl exec -it <pod> -n <ns> -- /bin/sh          # shell into container
kubectl get events -n <ns> --sort-by=.lastTimestamp | tail -20
kubectl top pods -n <ns>                           # resource usage (needs metrics-server)
```

## Common failures + fixes

| Symptom | Root cause | Fix |
|---|---|---|
| `ImagePullBackOff` | Wrong tag, missing creds, registry down | Check `imagePullSecrets`, verify tag exists |
| `CrashLoopBackOff` | App crashing on start | `kubectl logs --previous`, check env vars |
| `Pending` (no node) | No node has resources | `kubectl describe pod` → events; scale cluster |
| `Pending` (PVC) | Storage class wrong / no PV | Check StorageClass exists, dynamic provisioning works |
| `503 from ingress` | Service selector wrong, pods not ready | `kubectl get endpoints <svc>` should show pods |
| OOMKilled | Memory limit too low | Bump `resources.limits.memory`, check for leak |
| Random restarts | Liveness probe too aggressive | Increase `initialDelaySeconds` / `periodSeconds` |

## Scaling patterns

| Type | Use |
|---|---|
| Manual: `kubectl scale deployment/api --replicas=5` | One-off |
| HPA (CPU/memory) | Auto-scale on resource pressure |
| HPA (custom metric) | Scale on req/sec, queue depth (needs metrics adapter) |
| VPA | Auto-tune resource requests (caution: pod restarts) |
| Cluster Autoscaler | Add/remove nodes when pods can't schedule |

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: { name: api }
spec:
  scaleTargetRef: { apiVersion: apps/v1, kind: Deployment, name: api }
  minReplicas: 3
  maxReplicas: 20
  metrics:
    - type: Resource
      resource: { name: cpu, target: { type: Utilization, averageUtilization: 70 } }
```

## Secrets management

- Don't commit Secret yaml. Use external-secrets-operator (with Vault / AWS Secrets Manager / etc.)
- Or: SOPS-encrypted secrets in git, decrypted at apply time
- For dev only: `kubectl create secret generic ... --from-literal=...`

## Helm vs raw manifests

| When | Pick |
|---|---|
| 1-2 services, simple | Raw + kustomize |
| Many services, multi-env | Helm with values per env |
| Need templating / loops | Helm |
| Need GitOps | ArgoCD or Flux + raw or Helm |

## Anti-patterns

- No resource requests/limits (pods get OOMKilled or starve cluster)
- `latest` image tag (no rollback story)
- Liveness probe with no readiness probe (causes restart loops at startup)
- Secrets in env vars committed to git
- Cluster-admin RBAC for app service accounts (huge blast radius)
- One ingress for everything (no isolation, slow blast radius)
- Forgetting PodDisruptionBudgets for HA workloads

## Integration

- `nc-incident-response` — k8s-aware incident playbook
- `nc-terraform` — provision the k8s cluster
- `nc-deploy-vps` — for non-k8s deploys (alternative path)
- `nc-observability` — Prometheus + Grafana on k8s
- `nc-backup-recovery` — Velero for k8s backups
- `nc-security` — kube-bench, network policies, RBAC audit
