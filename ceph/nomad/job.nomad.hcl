variables {
  versions = {
    ceph = "17.2"
  }
}

job "ceph" {
  datacenters = ["syria"]
  namespace   = "infra"

  group "ceph-mon" {
    count = 3

    network {
      mode = "host"

      port "mon" {
        static = 3300
      }
    }

    volume "ceph-mon" {
      type   = "host"
      source = "ceph-mon"
    }

    task "ceph-mon" {
      driver = "docker"

      kill_signal  = "SIGINT"
      kill_timeout = "90s"

      volume_mount {
        volume      = "ceph-mon"
        destination = "/var/lib/ceph/mon"
      }

      config {
        image        = "quay.io/ceph/ceph:v${var.versions.ceph}"
        network_mode = "host"
        ports = [
          "mon",
        ]

        command = "ceph-mon"
        args = [
          "-i=${node.unique.name}",
          "-d",
          "--conf=/local/ceph.conf",
          "--mon-data=/var/lib/ceph/mon",
          "--cluster=ceph",
        ]
      }

      resources {
        cpu        = 500
        memory     = 256
        memory_max = 1024
      }

      template {
        data        = file("ceph.conf")
        destination = "local/ceph.conf"
      }
    }
  }
}
