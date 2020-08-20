resource "kubernetes_persistent_volume_claim" "my-pvc" {
	metadata {
		name = "my-pvc"
	}
	
	spec {
		volume_name = kubernetes_persistent_volume.my-pv.metadata.0.name
		access_modes = ["ReadWriteMany"]
		resources {
			requests = {
				storage = ".5Gi"
			}
		}
	}
}
