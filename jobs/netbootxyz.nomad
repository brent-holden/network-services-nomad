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
      port "netbootxyz" {
        static        = 3000
        host_network  = "lab"
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
          limit = 10000
          grace = "60s"
        }
      }
    }

    task "netbootxyz" {
      driver = "containerd-driver"

      env {
        PGID = "1000"
        PUID = "1000" 
      }

      config {
        image         = "docker.io/linuxserver/netbootxyz:latest"
        host_network  = true
        mounts        = [
                          {
                            type    = "bind"
                            target  = "/config"
                            source  = "/opt/netbootxyz/config"
                            options = ["rbind", "rw"]
                          },
                          {
                            type    = "bind"
                            target  = "/assets"
                            source  = "/opt/netbootxyz/assets"
                            options = ["rbind", "rw"]
                          }
                        ]
      }

      template {
        data          = <<EOH
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
