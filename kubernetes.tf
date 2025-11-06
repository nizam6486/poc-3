resource "kubernetes_namespace" "itop" {
  metadata {
    name = "itop"
  }
  depends_on = [module.eks]
}

resource "kubernetes_secret" "itop_db" {
  metadata {
    name      = "itop-db-secret"
    namespace = kubernetes_namespace.itop.metadata[0].name
  }

  data = {
    DB_HOST     = aws_db_instance.itop.endpoint
    DB_NAME     = aws_db_instance.itop.db_name
    DB_USER     = aws_db_instance.itop.username
    DB_PASSWORD = random_password.db_password.result
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "itop_config" {
  metadata {
    name      = "itop-config"
    namespace = kubernetes_namespace.itop.metadata[0].name
  }

  data = {
    ITOP_DB_HOST = aws_db_instance.itop.endpoint
    ITOP_DB_NAME = aws_db_instance.itop.db_name
  }
}

resource "kubernetes_deployment" "itop" {
  metadata {
    name      = "itop"
    namespace = kubernetes_namespace.itop.metadata[0].name
    labels = {
      app = "itop"
    }
  }

  spec {
    replicas = 2
    
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "25%"
        max_surge       = "25%"
      }
    }

    selector {
      match_labels = {
        app = "itop"
      }
    }

    template {
      metadata {
        labels = {
          app = "itop"
        }
      }

      spec {
        container {
          image = "vbkunin/itop:latest"
          name  = "itop"

          port {
            container_port = 80
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.itop_db.metadata[0].name
            }
          }
          
          env_from {
            config_map_ref {
              name = kubernetes_config_map.itop_config.metadata[0].name
            }
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 60
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }
      }
    }
  }

  depends_on = [aws_db_instance.itop]
}

resource "kubernetes_service" "itop" {
  metadata {
    name      = "itop-service"
    namespace = kubernetes_namespace.itop.metadata[0].name
  }

  spec {
    selector = {
      app = "itop"
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "itop" {
  metadata {
    name      = "itop-ingress"
    namespace = kubernetes_namespace.itop.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\": 80}]"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.itop.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.aws_load_balancer_controller]
}