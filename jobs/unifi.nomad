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
        type      = "tcp"
        port      = "web-admin"
        interval  = "60s"
        timeout   = "10s"
      }
    }

    task "unifi" {
      driver = "containerd-driver"

      env {
        PUID  = "1000"
        PGID  = "1000"
      }

      config {
        image         = "docker.io/linuxserver/unifi-controller:${RELEASE}"
        host_network  = true

        mounts        = [
                          {
                            type    = "bind"
                            target  = "/config"
                            source  = "/opt/unifi"
                            options = ["rbind", "rw"]
                          }
                    ]
      }

      template {
        data          = <<EOH
IMAGE_DIGEST={{ keyOrDefault "unifi/config/image_digest" "1" }}
RELEASE={{ keyOrDefault "unifi/config/release" "latest" }}
EOH
        destination   = "env_info"
        env           = true
      }

      resources {
        cpu    = 500
        memory = 2048
      }

      kill_timeout = "30s"
    }
  }
}
