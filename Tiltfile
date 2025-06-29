load('ext://helm_resource', 'helm_resource', 'helm_repo')
load('ext://helm_remote', 'helm_remote')
load('ext://secret', 'secret_create_generic', 'secret_yaml_generic')
load('ext://namespace', 'namespace_create')
load('ext://configmap', 'configmap_create')

allow_k8s_contexts([
    'k3d'
])


update_settings (max_parallel_updates = 5,  k8s_upsert_timeout_secs = 300)

# repos
helm_repo('jetstack', 'https://charts.jetstack.io')
helm_repo('argo', 'https://argoproj.github.io/argo-helm')
helm_repo('mojo2600', 'https://mojo2600.github.io/pihole-kubernetes/')
helm_repo('external-secrets-operator', 'https://charts.external-secrets.io/')

# charts
helm_resource(
  'argo-cd',
  chart='argo/argo-cd',
  namespace='argocd',
  flags=['--version=7.7.5', '-f', 'argocd/values.yaml', '--create-namespace'],
  resource_deps=['cluster-tls'],
  labels=['baseline'],
)

helm_resource(
  'cert-manager',
  chart='jetstack/cert-manager',
  namespace='cert-manager',
  flags=['--version=1.16.1', '--set', 'installCRDs=true', '--create-namespace'],
  resource_deps=[],
  labels=['baseline'],
)

helm_resource(
  'argo-rollouts',
  chart='argo/argo-rollouts',
  namespace='argocd',
  flags=['--version=2.39.1', '--create-namespace'],
  resource_deps=['argo-cd'],
  labels=['baseline'],
)

helm_resource(
  'eso',
  chart='external-secrets-operator/external-secrets',
  namespace='external-secrets',
  flags=['--version=0.18.0', '--set', 'installCRDs=true',  '--create-namespace'],
  resource_deps=['cluster-tls'],
  labels=['baseline'],
)

# secrets 
# argo_git_creds_yaml = secret_yaml_generic(
#   'argo-gh-credentials',
#   from_env_file='.env.gh',
#   namespace='argocd'
# )
# argo_git_creds_yaml_obj = decode_yaml_stream(argo_git_creds_yaml)[0]
# if 'repoURL' in argo_git_creds_yaml_obj['data']:
#   argo_git_creds_yaml_obj['data']['url'] = argo_git_creds_yaml_obj['data'].pop('repoURL') # why? i dont know why kargo devs are tripping
# if 'labels' not in argo_git_creds_yaml_obj['metadata']:
#     argo_git_creds_yaml_obj['metadata']['labels'] = {}
# argo_git_creds_yaml_obj['metadata']['labels']['argocd.argoproj.io/secret-type'] = 'repository'
# k8s_yaml(encode_yaml_stream([argo_git_creds_yaml_obj]))
# k8s_resource(
#   objects=['argo-gh-credentials:secret'],
#   new_name='argo-gh-creds',
#   resource_deps=['argo-cd'],
#   labels=['baseline'],
# )

# k8s_resource(
#   objects=['azure-key-vault-credentials:Secret'],
#   new_name='argocd-server-secrets',
#   resource_deps=['argo-cd'],
#   labels=['baseline'],
# )

k8s_yaml('argocd/argocd-server-secrets.yaml')
k8s_resource(
  objects=['azure-key-vault-credentials', 'azure-keyvault:clustersecretstore'],
  new_name='external-secrets',
  resource_deps=[],
  labels=['baseline'],
)

# ingress
k8s_yaml('argocd/ingress.yaml')
k8s_resource(
  objects=["argocd:namespace", "letsencrypt-prod-cloudflare:ClusterIssuer"],
  new_name='cluster-tls',
  resource_deps=['cert-manager'],
  labels=['ingress-tls'],
)

# main root app
k8s_yaml('argocd/homelab-root.yaml')
k8s_resource(
  objects=['homelab-root:Application'],
  new_name='homelab-root',
  resource_deps=['argo-cd', 'cert-manager'],
  labels=['baseline'],
)
