job "pihole" {
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

  group "pihole" {
    count = 1

    restart {
      interval  = "12h"
      attempts  = 720
      delay     = "60s"
      mode      = "delay"
    }

    network {
      port "dns" { static = 53 }
      port "http" { static = 80 }
    }

    task "pihole" {
      driver = "containerd-driver"

      service {
        name = "pihole"
        tags = ["http","dns"]
        port = "dns"

        check {
          type     = "tcp"
          port     = "dns"
          interval = "30s"
          timeout  = "5s"

          check_restart {
            limit = 10000
            grace = "60s"
          }
        }

        check {
          type      = "http"
          port      = "http"
          path      = "/admin/"
          interval  = "30s"
          timeout   = "5s"

          check_restart {
            limit = 10000
            grace = "60s"
          }
        }
      }

      env {
        ServerIP          = "192.168.0.2"
        INTERFACE         = "enp0s20f0"
        DNSMASQ_LISTENING = "all"
        TZ                = "America/New_York"
      }

      config {
        image         = "docker.io/pihole/pihole:${RELEASE}"
        host_network  = true
        mounts        = [
                          {
                            type    = "bind"
                            target  = "/etc/pihole"
                            source  = "/opt/pihole/etc"
                            options = ["rbind", "rw"]
                          },
                          {
                            type    = "bind"
                            target  = "/etc/dnsmasq.d"
                            source  = "/opt/pihole/dnsmasq.d"
                            options = ["rbind", "rw"]
                          }
                    ]
      }

      template {
        data          = <<EOH
IMAGE_DIGEST={{ keyOrDefault "pihole/config/image_digest" "1" }}
RELEASE={{ keyOrDefault "pihole/config/release" "latest"}}
EOH
        destination   = "env_info"
        env           = true
      }

      resources {
        cpu    = 300
        memory = 512
      }

      kill_timeout = "30s"
    }
  }
}
