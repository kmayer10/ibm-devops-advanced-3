resource "kubernetes_deployment" "my-deploy" {
  metadata {
    name = "my-deploy"
    namespace = kubernetes_namespace.my-ns.metadata.0.name
    labels = {
      test = "my-deploy"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        test = "my-deploy"
      }
    }

    template {
      metadata {
        labels = {
          test = "my-deploy"
        }
      }

      spec {
        container {
          image = "nginx:1.7.8"
          name  = "nginx"
        }
      }
    }
  }
}
