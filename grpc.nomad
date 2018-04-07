job "grpc" {
  datacenters = ["dc1"]
  type = "service"

  group "lb" {
    count = 1
    task "traefik" {
      driver = "raw_exec"
      config {
        command = "/Users/alextanhongpin/Documents/architecture/traefik-grpc/traefik_darwin-amd64"
        args = [
          "--configFile=local/traefik.toml"
        ]
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "admin" {
            static = 8080
          }
          port "frontend" {
            static = 80
          }
          port "https" {
            static = 4443
          }
        }
      }

      service {
        name = "traefik"
        tags = ["load-balancer"]
        port = "admin"
      }

      template {
        source = "/Users/alextanhongpin/Documents/architecture/traefik-grpc/traefik.toml.tpl"
        // destination   = "/Users/alextanhongpin/Documents/architecture/traefik-grpc/traefik.toml"
        destination   = "local/traefik.toml"
        change_mode   = "restart"
        change_signal = "SIGINT"
      }
      # The "template" stanza instructs Nomad to manage a template, such as
      # a configuration file or script. This template can optionally pull data
      # from Consul or Vault to populate runtime configuration data.
      #
      # For more information and examples on the "template" stanza, please see
      # the online documentation at:
      #
      #     https://www.nomadproject.io/docs/job-specification/template.html
      #
      # template {
      #   data          = "---\nkey: {{ key \"service/my-key\" }}"
      #   destination   = "local/file.yml"
      #   change_mode   = "signal"
      #   change_signal = "SIGHUP"
      # }

      # The "template" stanza can also be used to create environment variables
      # for tasks that prefer those to config files. The task will be restarted
      # when data pulled from Consul or Vault changes.
      #
      # template {
      #   data        = "KEY={{ key \"service/my-key\" }}"
      #   destination = "local/file.env"
      #   env         = true
      # }
    }
  }

  group "grpc" {
    count = 3
    task "server" {
      driver = "raw_exec"
      config {
        command = "/Users/alextanhongpin/Documents/architecture/traefik-grpc/server/server"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
        network {
          mbits = 10
          port "tcp" {
            // static = 50051
          }
        }
      }

      env {
        PORT = "${NOMAD_PORT_tcp}"
      }

      service {
        name = "server"
        tags = [
          "grpc", 
          "server"
        ]
        port = "tcp"
      }
    }
  }
}