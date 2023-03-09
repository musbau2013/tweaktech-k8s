# data "kubectl_file_documents" "ingresss_deploy" {
#   content = file("argocd-demo/k8s-yamls/ingress.yaml")
# }

# resource "kubectl_manifest" "ingresss_deploy" {
#   for_each  = data.kubectl_file_documents.ingresss_deploy.manifests
#   yaml_body = each.value
# }

