job "netbootxyz" {
  datacenters = ["lab"]
  type = "service"

  constraint {
    attribute = "${meta.network_node}"
    value     = "true"
  }

  update {
    max_parallel = 1
    min_healthy_time = "5s"
    healthy_deadline = "2m"
    progress_deadline = "3m"
    auto_revert = true
    canary = 0
  }

  group "netbootxyz" {
    count = 1
    network {
      port "netbootxyz" {
        static = 3000
        host_network = "lab"
      }
      port "tftp" {
        static = 69
        host_network = "lab"
     }
      port "webconsole" {
        static = 8000
        to = 80
        host_network = "lab"
      }
    }

    service {
      name = "netbootxyz"
      tags = ["http","provisioning"]
      port = "netbootxyz"

#      check {
#        type     = "tcp"
#	port     = "netbootxyz"
#        interval = "60s"
#        timeout  = "2s"
#      }
    }

    ephemeral_disk {
      sticky = true
      size = 2048
    }


    task "netbootxyz" {
      driver = "podman"

      env {
       PGID = "1000"
       PUID = "1000" 
      }

      config {
        image = "docker://linuxserver/netbootxyz:latest"
        network_mode = "bridge"
        ports = ["netbootxyz", "tftp", "webconsole"]
        volumes = ["/opt/netbootxyz/config:/config","/opt/netbootxyz/assets:/assets"]

        cap_add = [
          "NET_ADMIN"
        ]

      }

      resources {
        cpu    = 3000
        memory = 1048
      }

      kill_timeout = "20s"
    }
  }
}
