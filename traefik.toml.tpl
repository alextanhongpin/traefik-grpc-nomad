debug = true

defaultEntryPoints = ["https"]
InsecureSkipVerify = true

# For secure connection on backend.local
RootCAs = [ "/Users/alextanhongpin/Documents/architecture/traefik-grpc/backend.cert" ]

[entryPoints]
  [entryPoints.http]
  address = ":80"
    [entryPoints.http.redirect]
    entryPoint = "https"
  [entryPoints.https]
  address = ":4443"
    [entryPoints.https.tls]
     # For secure connection on frontend.local
        [[entryPoints.https.tls.certificates]]
        certFile = "/Users/alextanhongpin/Documents/architecture/traefik-grpc/frontend.cert"
        keyFile  = "/Users/alextanhongpin/Documents/architecture/traefik-grpc/frontend.key"


[web]
  address = ":8080"

[file]

[backends]
  [backends.backend1]

    {{- range $key, $value := service "server" }}
    [backends.backend1.servers.{{.ID}}]
    # Access on backend with HTTPS
    # url = "https://backend.local:{{index .NodeMeta "port"}}"
    url = "https://backend.local:{{.Port}}"
    {{- end }}



[frontends]
  [frontends.frontend1]
  backend = "backend1"
    [frontends.frontend1.routes.Echo]
    rule = "Host:frontend.local"