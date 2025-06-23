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
  config_path = "~/.kube/config" # Assumes your kubeconfig is in the default location
}

# Configure the Helm provider to use the same connection
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}