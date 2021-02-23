job "netbootxyz" {
  datacenters = ["lab"]
  type        = "service"

  constraint {
    attribute = "${meta.network_node}"
    value     = "true"
  }

  update {
    max_parallel      = 1
    min_healthy_time  = "5s"
    healthy_deadline  = "2m"
    progress_deadline = "3m"
    auto_revert       = true
    canary            = 0
  }

  group "netbootxyz" {
    count = 1
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
        type     = "tcp"
        port     = "netbootxyz"
        interval = "60s"
        timeout  = "5s"
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
        data          = "IMAGE_DIGEST={{ keyOrDefault \"netbootxyz/config/image_digest\" \"1\" }}\nRELEASE={{ keyOrDefault \"netbootxyz/config/release\" \"latest\"}}"
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
