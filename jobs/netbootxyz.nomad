job "netbootxyz" {
  datacenters = ["lab"]
  type        = "service"

  constraint {
    attribute = "${meta.network_node}"
    value     = "true"
  }

  update {
    max_parallel  = 0
    health_check  = "checks"
    auto_revert   = true
  }

  group "netbootxyz" {
    count = 1

    restart {
      interval  = "12h"
      attempts  = 720
      delay     = "60s"
      mode      = "delay"
    }

    network {
      mode  = "bridge"
      port "netbootxyz" {
        static        = 3000
        host_network  = "default"
      }
      port "tftp" {
        static        = 69
        host_network  = "lab"
     }
      port "webconsole" {
        static        = 8000
        host_network  = "lab"
      }
    }

    service {
      name = "netbootxyz"
      tags = ["http","provisioning"]
      port = "netbootxyz"

      check {
        type      = "http"
        port      = "netbootxyz"
        path      = "/"
        interval  = "30s"
        timeout   = "2s"

        check_restart {
          limit = 2
          grace = "10s"
        }
      }
    }

    task "netbootxyz" {
      driver = "docker"

      env {
        PGID = "1000"
        PUID = "1000" 
      }

      config {
        image         = "docker.io/linuxserver/netbootxyz:latest"

        mount {
          type    = "bind"
          target  = "/config"
          source  = "/opt/netbootxyz/config"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }

        mount {
          type    = "bind"
          target  = "/assets"
          source  = "/opt/netbootxyz/assets"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }

      }

      template {
        data          = <<-EOH
          IMAGE_DIGEST={{ keyOrDefault "netbootxyz/config/image_digest" "1" }}
          RELEASE={{ keyOrDefault "netbootxyz/config/release" "latest" }}
          EOH
        destination   = "env_info"
        env           = true
      }

      resources {
        cpu    = 3000
        memory = 1048
      }

      kill_timeout = "20s"
    }
  }
}
