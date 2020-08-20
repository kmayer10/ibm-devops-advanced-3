resource "kubernetes_namespace" "my-ns" {
	metadata {
		name = "my-ns"
	}
}
