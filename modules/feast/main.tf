
resource "kubernetes_secret" "feast_postgresql_secret" {
  metadata {
    name      = "feast-postgresql"
    namespace = var.namespace
  }
  data = {
    postgresql-password = var.feast_postgresql_password
  }
}


resource "helm_release" "feast" {
  name      = "feast"
  namespace = var.namespace

  repository = "https://feast-charts.storage.googleapis.com"
  chart      = "feast"
  version    = "0.8.2"


  set {
    name  = "feast-core.enabled"
    value = var.feast_core_enabled
  }

  set {
    name  = "feast-core.postgresql.existingSecret"
    value = kubernetes_secret.feast_postgresql_secret.metadata[0].name
  }

  set {
    name  = "feast-online-serving.enabled"
    value = var.feast_online_serving_enabled
  }

  set {
    name  = "feast-jupyter.enabled"
    value = var.feast_jupyter_enabled
  }

  set {
    name  = "feast-jobservice.enabled"
    value = var.feast_jobservice_enabled
  }

  set {
    name  = "feast-jobservice.enabled"
    value = var.feast_jobservice_enabled
  }

  set {
    name  = "postgresql.enabled"
    value = var.feast_posgresql_enabled
  }

  set {
    name  = "postgresql.existingSecret"
    value = kubernetes_secret.feast_postgresql_secret.metadata[0].name
  }

  set {
    name  = "kafka.enabled"
    value = var.feast_kafka_enabled
  }

  set {
    name  = "redis.enabled"
    value = var.feast_redis_enabled
  }

  set {
    name  = "redis.use_password"
    value = var.feast_redis_use_password
  }

  set {
    name  = "redis.master.disableCommands"
    value = var.feast_redis_disable_commands
  }

  set {
    name  = "redis.slave.disableCommands"
    value = var.feast_redis_disable_commands
  }

  set {
    name  = "prometheus-statsd-exporter.enabled"
    value = var.feast_prometheus_statsd_exporter_enabled
  }

  set {
    name  = "prometheus.enabled"
    value = var.feast_prometheus_enabled
  }

  set {
    name  = "grafana.enabled"
    value = var.feast_grafana_enabled
  }
}


resource "helm_release" "spark" {
  name      = "feast-spark"
  namespace = var.namespace

  repository = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
  chart      = "spark-operator"
  version    = "1.0.6"

  set {
    name  = "serviceAccounts.spark.name"
    value = "spark"
  }

  set {
    name  = "image.tag"
    value = var.feast_spark_operator_image_tag
  }
}

resource "kubernetes_role" "use_spark_operator" {
  metadata {
    name = "use-spark-operator"
    namespace = var.namespace
  }
  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources = ["sparkapplications"]
    verbs = ["create", "delete", "deletecollection", "get", "list", "update", "watch", "patch"]
  }
}

resource "kubernetes_role_binding" "use_spark_operator" {
  metadata {
    name = "use-spark-operator"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = kubernetes_role.use_spark_operator.metadata[0].name
  }
  subject {
    kind = "ServiceAccount"
    name = "default"
  }
}

resource "kubernetes_cluster_role" "use_spark_operator" {
  metadata {
    name = var.feast_spark_operator_cluster_role_name
  }
  rule {
    api_groups = ["sparkoperator.k8s.io"]
    resources = ["sparkapplications"]
    verbs = ["create", "delete", "deletecollection", "get", "list", "update", "watch", "patch"]
  }
}