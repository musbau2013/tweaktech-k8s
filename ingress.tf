# resource "kubernetes_ingress_v1" "example_ingress" {
#   metadata {
#     name = var.app
#     namespace = kubernetes_namespace.example.metadata.0.name
#   }

#   spec {
#     backend {
#       service_name = var.app
#       service_port = 80
#     }

#     rule {
#       http {
#         path {
#           backend {
#             service_name = var.app_printer
#             service_port = 80
#           }

#           path = "/${var.app_printer}/*"
#         }

#         path {
#           backend {
#             service_name = var.whereami
#             service_port = 80
#           }

#           path = "/${var.whereami}/*"
#         }
#       }
#     }

#     tls {
#       secret_name = "tls-secret"
#     }
#   }
#   depends_on = [
#     kubernetes_service.app,
#     kubernetes_namespace.example,
#   ]
# }

# # output "ingress_ip" {
# # #   value = data.kubernetes_ingress.example.status[0].ip
# # value = kubernetes_ingress.example_ingress.status[0].ip
# # }
resource "kubernetes_ingress_v1" "example_ingress" {
  wait_for_load_balancer = true
  metadata {
    name      = var.app
    namespace = kubernetes_namespace.example.metadata.0.name

  }

  spec {
    default_backend {
      service {
        name = var.app
        port {
          number = 8000
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = var.app_printer
              port {
                number = 9000
              }
            }
          }

          path = "/${var.app_printer}"
        }

        path {
          backend {
            service {
              name = var.whereami
              port {
                number = 10000
              }
            }
          }

          path = "/${var.whereami}"
        }
      }
    }

    # tls {
    #   secret_name = "tls-secret"
    # }
  }
  depends_on = [
    kubernetes_service.app,
    kubernetes_service.zone_printer_service,
    kubernetes_service.whereami_service,
    kubernetes_namespace.example

  ]
}

output "load_balancer_id" {
  value = kubernetes_ingress_v1.example_ingress.status.0.load_balancer.0.ingress.0.ip
}