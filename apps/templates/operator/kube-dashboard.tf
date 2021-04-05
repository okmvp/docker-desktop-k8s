apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kube-dashboard
  namespace: argo
  labels:
    argo.okmvp.internal/category: operator
spec:
  project: default
  source:
    repoURL: {{ .Values.repository }}
    targetRevision: {{ .Values.revision }}
    path: helm/operator/kube-dashboard
    helm:
      parameters:
      - name:  dashboard.ingress.hosts[0]
        value: k8s.{{ .Values.domain }}
      valueFiles:
      - values.yaml
      version: v2
  destination:
    server: https://kubernetes.default.svc
    namespace: kube-dashbaord
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - Validate=true
    - CreateNamespace=true
