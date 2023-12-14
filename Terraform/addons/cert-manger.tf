resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.helm_certmanager_version
  namespace        = "cert-manager"
  timeout          = 300
  create_namespace = true
  set {
    name  = "installCRDs"
    value = "true"
  }
  depends_on = [helm_release.external-dns]
}

resource "kubernetes_secret" "certmanager-route53-credentials" {
  metadata {
    name      = "certmanager-route53-credentials"
    namespace = "cert-manager"
  }

  data = {
    secret-access-key = aws_iam_access_key.route53-external-dns.secret
  }

  type       = "opaque"
  depends_on = [helm_release.cert-manager]
}
resource "kubectl_manifest" "lets-encrypt-issuer" {
  yaml_body = templatefile("${path.module}/templates/letsencrypt-cluster-issuer.yaml.tpl", {
    external_dns_iam_access_key = aws_iam_access_key.route53-external-dns.id
    region                      = var.region
    domain                      = var.domain
    letsencrypt_server          = var.letsencrypt_server == "production" ? "https://acme-v02.api.letsencrypt.org/directory" : "https://acme-staging-v02.api.letsencrypt.org/directory"
    letsencrypt_email           = var.letsencrypt_admin_email
    secret_name                 = kubernetes_secret.certmanager-route53-credentials.metadata[0].name
    issuer_name                 = "letsencrypt"
  })
  override_namespace = "cert-manager"
  depends_on         = [helm_release.cert-manager]
}


resource "time_sleep" "wait_90_seconds-issuer" {
  depends_on       = [kubectl_manifest.lets-encrypt-issuer]
  create_duration  = "90s"
  destroy_duration = "90s"
}