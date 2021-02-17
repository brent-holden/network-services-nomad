job "unifi" {
  datacenters = ["lab"]
  type        = "service"
  priority    = 2

  constraint {
    attribute = "${meta.network_node}"
    value     = "true"
  }

  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "5s"
    healthy_deadline  = "2m"
    progress_deadline = "3m"
    auto_revert       = true
    canary            = 0
  }

  group "unifi" {
    count = 1

    restart {
      interval  = "2h"
      attempts  = 10
      delay     = "60s"
      mode      = "delay"
    }

    network {
      port "stun" { static = 3478 }
      port "ap-disco" { static = 10001 }
      port "dev-comms" { static = 8080 }
      port "web-admin" { static = 8443 }
      port "disco" { static = 1900 }
      port "guest-portal-https" { static = 8843 }
      port "guest-portal-http" { static = 8880 }
      port "throughput" { static = 6789 }
      port "rsyslog" { static = 5514 }
    }

    service {
      name = "unifi"
      tags = ["http","unifi"]
      port = "web-admin"

      check {
        type      = "http"
        protocol  = "https"
        tls_skip_verify = "true"
        port      = "web-admin"
        path      = "/manage/account/login"
        interval  = "30s"
        timeout   = "5s"

        check_restart {
          limit = 2
          grace = "60s"
        }
      }
    }

    ephemeral_disk {
      sticky  = true
      size    = 512
    }

    task "unifi" {
      driver = "podman"

      env {
        PUID  = "1000"
        PGID  = "1000"
      }

      config {
        image         = "docker://docker.io/linuxserver/unifi-controller:${RELEASE}"
        network_mode  = "host"
        ports         = ["stun", "ap-disco", "dev-comms", "web-admin", "disco", "guest-portal-https", "guest-portal-http", "throughput", "rsyslog"]
        volumes       = ["/opt/unifi:/config"]
      }

      template {
        data          = "IMAGE_ID={{ keyOrDefault \"unifi/config/image_id\" \"1\" }}\nRELEASE={{ keyOrDefault \"unifi/config/release\" \"latest\"}}"
        destination   = "env_info"
        env           = true
      }

      resources {
        cpu    = 500
        memory = 1024
      }

      kill_timeout = "30s"
    }
  }
}
