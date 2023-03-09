resource "google_service_account" "default" {
  project      = "global-matrix-374023"
  account_id   = "my-gke-cluster"
  display_name = "Service Account"

}

resource "google_container_cluster" "primary" {
  project    = "global-matrix-374023"
  name       = "my-gke-cluster"
  location   = "us-central1"
  network    = "paypay-vpc"
  subnetwork = "paypal-appserver-network"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  depends_on = [
    google_service_account.default,
  ]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  project    = "global-matrix-374023"
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 1


  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "kubernetes_namespace" "example" {
  timeouts {
    # create = "10m"
    delete = "5m"
  }


  # for_each = { for i in var.namespace : i => i }

  metadata {
    name = var.namespace

    #   count    = data.google_secret_manager_secret.existing_secret.id == null ? 1 : 0
    #   for_each  = { for name in var.secret_id : name => name if data.google_secret_manager_secret.existing_secrets[name] == null}

    # name = each.key
  }
  depends_on = [
    google_container_cluster.primary,
  ]
}

output "get_node_pool" {
  value = google_container_node_pool.primary_preemptible_nodes.instance_group_urls
}