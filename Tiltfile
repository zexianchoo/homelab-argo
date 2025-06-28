load('ext://helm_resource', 'helm_resource', 'helm_repo')
load('ext://helm_remote', 'helm_remote')
load('ext://secret', 'secret_create_generic', 'secret_yaml_generic')
load('ext://namespace', 'namespace_create')
load('ext://configmap', 'configmap_create')

allow_k8s_contexts([
    'k3d'
])

update_settings (max_parallel_updates = 5,  k8s_upsert_timeout_secs = 300)
namespace_create('cert-manager')
namespace_create('argocd')

k8s_resource(
  objects=['cert-manager:namespace', 'argocd:namespace'],
  new_name='namespace',
  labels=['baseline'],
)

# jic helm repo is not installed
helm_repo('jetstack', 'https://charts.jetstack.io')
helm_repo('argo', 'https://argoproj.github.io/argo-helm')
helm_repo('mojo2600', 'https://mojo2600.github.io/pihole-kubernetes/')

# baseline resources
helm_resource(
  'cert-manager',
  chart='jetstack/cert-manager',
  namespace='cert-manager',
  flags=['--version=1.16.1', '--set', 'installCRDs=true'],
  resource_deps=['namespace'],
  labels=['baseline'],
)

argo_git_creds_yaml = secret_yaml_generic(
  'argo-gh-credentials',
  from_env_file='.env.gh',
  namespace='argocd'
)
argo_git_creds_yaml_obj = decode_yaml_stream(argo_git_creds_yaml)[0]
if 'repoURL' in argo_git_creds_yaml_obj['data']:
  argo_git_creds_yaml_obj['data']['url'] = argo_git_creds_yaml_obj['data'].pop('repoURL') # why? i dont know why kargo devs are tripping
if 'labels' not in argo_git_creds_yaml_obj['metadata']:
    argo_git_creds_yaml_obj['metadata']['labels'] = {}
argo_git_creds_yaml_obj['metadata']['labels']['argocd.argoproj.io/secret-type'] = 'repository'
k8s_yaml(encode_yaml_stream([argo_git_creds_yaml_obj]))

k8s_resource(
  objects=['argo-gh-credentials:secret'],
  new_name='argo-gh-creds',
  resource_deps=['namespace'],
  labels=['baseline'],
)

k8s_yaml('argocd/ingress.yaml')
k8s_yaml('argocd/argocd-repo-secret.yaml')
k8s_resource(
  objects=["letsencrypt-staging-cloudflare:ClusterIssuer", "argocd-server:IngressRoute", "argo-server-cert:Certificate", "cloudflare-api-token-secret:Secret"],
  new_name='cluster-tls',
  resource_deps=['namespace', 'cert-manager'],
  labels=['tls'],
)

helm_resource(
  'argo-cd',
  chart='argo/argo-cd',
  namespace='argocd',
  flags=['--version=7.7.5', '-f', 'argocd/values.yaml'],
  resource_deps=['namespace', 'argo-gh-creds', 'cluster-tls'],
  labels=['baseline'],
)

helm_resource(
  'argo-rollouts',
  chart='argo/argo-rollouts',
  namespace='argocd',
  flags=['--version=2.39.1'],
  resource_deps=['namespace', 'argo-gh-creds', 'cluster-tls'],
  labels=['baseline'],
)

# main root app
k8s_yaml('argocd/homelab-root.yaml')
k8s_resource(
  objects=['homelab-root:application'],
  new_name='homelab-root',
  resource_deps=['namespace', 'argo-cd', 'cert-manager'],
  labels=['baseline'],
)
