job "unifi" {
  datacenters = ["lab"]
  type        = "service"
  priority    = 2

  constraint {
    attribute = "${meta.network_node}"
    value     = "true"
  }

  update {
    max_parallel  = 0
    health_check  = "checks"
    auto_revert   = true
  }

  group "unifi" {
    count = 1

    restart {
      interval  = "12h"
      attempts  = 720
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
        type            = "http"
        port            = "web-admin"
        protocol        = "https"
        path            = "/manage/account/login"
        tls_skip_verify = true
        interval        = "30s"
        timeout         = "5s"

        check_restart {
          limit = 10000
          grace = "60s"
        }
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
        data          = "IMAGE_DIGEST={{ keyOrDefault \"unifi/config/image_digest\" \"1\" }}\nRELEASE={{ keyOrDefault \"unifi/config/release\" \"latest\"}}"
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
