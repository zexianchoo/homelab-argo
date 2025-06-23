# argocd.tf
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
  }

}

# Connect to your K8s cluster
provider "kubernetes" {
  config_path = "~/.kube/config" 
}

# Configure the Helm provider to use the same connection
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

# Deploy ArgoCD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "7.7.5" # Pinning versions is a good practice
  values = [
    yamlencode({
      configs = {
        secret = {
          # GCP stores the secret as a raw string, so we don't need jsondecode.
          argocdServerAdminPassword = "admin"
        }
      }
    })
  ]
}

# Deploy Traefik (our Ingress Controller)
resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  namespace  = "traefik"
  version    = "36.0.0"
}
