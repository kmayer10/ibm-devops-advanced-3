provider "kubernetes"{
	config_context = "kubernetes-admin@kubernetes"
}

resource "kubernetes_namespace" "my-ns" {
	metadata {
		name = "my-ns"
	}
}
