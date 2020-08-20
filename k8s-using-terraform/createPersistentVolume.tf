resource "kubernetes_persistent_volume" "my-pv"{
	metadata {
		name = "my-pv"
	}

	spec{
		capacity = {
			storage = "1Gi"
		}

		access_modes = ["ReadWriteMany"]
		persistent_volume_source {
			host_path {
				path = "/tmp/pv-demo"
				type = "DirectoryOrCreate"
			}
		}
	}
}
