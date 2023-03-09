# # # resource "kubernetes_service" "app" {
# # #   metadata {
# # #     name = "my-app"
# # #   }
# # #   spec {
# # #     selector = {
# # #       app = "my-app"
# # #     }
# # #     port {
# # #       name        = "http"
# # #       port        = 80
# # #       target_port = 8080
# # #     }
# # #     type = "NodePort"
# # #   }
# # # }

# # # resource "google_compute_region_target_http_proxy" "name" {

# # # }

# # # Create a Google Cloud Load Balancer
# # resource "google_compute_forwarding_rule" "lb" {
# #   project = "global-matrix-374023"
# #   name    = "my-lb"
# #   # ip_address            = "AUTO"
# #   load_balancing_scheme = "INTERNAL"
# #   network               = "paypay-vpc"
# #   subnetwork            = "paypal-appserver-network"
# #   # backend_service = 
# #   #   load_balancing_scheme = "EXTERNAL"

# #   port_range = "80-80"
# #   # target = 
# #   # target = google_container_node_pool.primary_preemptible_nodes.instance_group_urls

# #   depends_on = [
# #     google_container_cluster.primary,
# #   ]
# # }

# # resource "google_compute_global_address" "lb_ip" {
# #   project      = "global-matrix-374023"
# #   name         = "my-lb-ip"
# #   address_type = "INTERNAL"
# #   network      = "paypay-vpc"
# #   purpose      = "PRIVATE_SERVICE_CONNECT"

# # }

# # # resource "google_compute_forwarding_rule" "lb" {
# # #   name                  = "my-lb"
# # #   ip_address            = google_compute_global_address.lb_ip.address
# # #   load_balancing_scheme = "INTERNAL"
# # #   port_range            = "80-80"
# # #   # target                = google_compute_forwarding_rule.lb.self_link
# # #   network               = "paypay-vpc"
# # #   all_ports             = true
# # # }

# # resource "google_compute_health_check" "hc" {
# #   project            = "global-matrix-374023"
# #   name               = "check-website-backend"
# #   check_interval_sec = 1
# #   timeout_sec        = 1
# #   tcp_health_check {
# #     port = "80"
# #   }
# # }

# # resource "google_compute_region_backend_service" "backend" {
# #   project       = "global-matrix-374023"
# #   name          = "website-backend"
# #   region        = "us-central1"
# #   health_checks = ["${google_compute_health_check.hc.self_link}"]
# # }

# # # Update the Kubernetes service to use the external IP address of the Google Cloud Load Balancer as its endpoint
# # resource "kubernetes_service" "app" {

# #   metadata {
# #     name = "my-app"
# #   }
# #   spec {
# #     selector = {
# #       app = "my-app"
# #     }
# #     port {
# #       name        = "http"
# #       port        = 80
# #       target_port = 8080
# #     }
# #     type = "LoadBalancer"

# #     # Use the external IP address of the Google Cloud Load Balancer as the endpoint
# #     load_balancer_ip = google_compute_global_address.lb_ip.address
# #   }
# # }

# ##App A
resource "kubernetes_deployment" "app" {

  # for_each = { for i in var.namespace : i => i }
  metadata {
    name      = var.app
    namespace = kubernetes_namespace.example.metadata.0.name
    labels = {
      app = var.app
    }
  }
  spec {
    replicas = 3

    selector {
      match_labels = {
        app = var.app
      }
    }
    template {
      metadata {
        labels = {
          app = var.app
        }
      }
      spec {
        container {
          image = var.docker-image
          name  = var.app
          port {
            name           = "port-5000"
            container_port = 8080
          }
        }
      }
    }
  }
  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_preemptible_nodes,
  ]
}

resource "kubernetes_service" "app" {
  # timeouts {
  #   # create = "10m"
  #   delete = "5m"
  # }
  metadata {
    name      = var.app
    namespace = kubernetes_namespace.example.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.app.metadata.0.labels.app
    }
    port {
      port        = 8000
      target_port = 8080
    }
    type = "NodePort"
  }
  depends_on = [
    kubernetes_deployment.app,
  ]
}

#  output "endpoint" {
# #   # value = kubernetes_service.app.load_balancer_ingress.0.ip
#   value = kubernetes_service.app.ingress.ip
#  }

##App B

resource "kubernetes_deployment" "zone_printer_deployment" {

  metadata {
    name      = var.app_printer
    namespace = kubernetes_namespace.example.metadata.0.name
    labels = {
      app = var.app_printer
    }
  }
  spec {
    replicas = 3

    selector {
      match_labels = {
        app = var.app_printer
      }
    }
    template {
      metadata {
        labels = {
          app = var.app_printer
        }
      }
      spec {
        container {
          image = var.docker-image_zone_printer
          name  = var.app_printer
          port {
            name           = "port-5000"
            container_port = 8080
          }
        }
      }
    }
  }
  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_preemptible_nodes,
  ]
}

resource "kubernetes_service" "zone_printer_service" {
  # timeouts {
  #   # create = "10m"
  #   delete = "5m"
  # }
  metadata {
    name      = var.app_printer
    namespace = kubernetes_namespace.example.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.zone_printer_deployment.metadata.0.labels.app
    }
    port {
      port        = 9000
      target_port = 8080
    }
    type = "NodePort"
  }
  depends_on = [
    kubernetes_deployment.zone_printer_deployment,
  ]
}


resource "kubernetes_deployment" "whereami_deployment" {

  metadata {
    name      = var.whereami
    namespace = kubernetes_namespace.example.metadata.0.name
    labels = {
      app = var.whereami
    }
  }
  spec {
    replicas = 3

    selector {
      match_labels = {
        app = var.whereami
      }
    }
    template {
      metadata {
        labels = {
          app = var.whereami
        }
      }
      spec {
        container {
          image = var.docker-image_whereami
          name  = var.whereami
          port {
            name           = "port-5000"
            container_port = 8080
          }
        }
      }
    }
  }
  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_preemptible_nodes,
  ]
}

resource "kubernetes_service" "whereami_service" {

  metadata {
    name      = var.whereami
    namespace = kubernetes_namespace.example.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.whereami_deployment.metadata.0.labels.app
    }
    port {
      port        = 10000
      target_port = 8080
    }
    type = "NodePort"
  }
  depends_on = [
    kubernetes_deployment.whereami_deployment,
  ]
}