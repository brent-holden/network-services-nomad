job "pihole" {
  datacenters = ["lab"]
  type = "service"

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

  group "pihole" {
    count = 1

    restart {
      interval  = "2h"
      attempts  = 10
      delay     = "60s"
      mode      = "delay"
    }

    network {
      port "dns" { static = 53 }
      port "http" { static = 80 }
    }

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
          limit = 2
          grace = "60s"
        }
      }
    }

    ephemeral_disk {
      sticky  = true
      size    = 512
    }

    task "pihole" {
      driver = "podman"

      env {
        ServerIP          = "192.168.0.2"
        INTERFACE         = "enp0s20f0"
        DNSMASQ_LISTENING = "all"
        TZ                = "America/New_York"
      }

      config {
        image         = "docker://docker.io/pihole/pihole:${RELEASE}"
        network_mode  = "host"
        ports         = ["dns","http"]
        volumes       = ["/opt/pihole/etc:/etc/pihole","/opt/pihole/dnsmasq.d:/etc/dnsmasq.d"]
      }

      template {
        data          = "IMAGE_ID={{ keyOrDefault \"pihole/config/image_id\" \"1\" }}\nRELEASE={{ keyOrDefault \"pihole/config/release\" \"latest\"}}"
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