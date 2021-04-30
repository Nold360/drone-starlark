def main(ctx):
  data = list([
		dict(name="talosctl", versions=["v0.9.1"], repo="https://github.com/talos-systems/talos", build="cd cmd/talosctl ; go build", image="golang:latest", binary='cmd/talosctl/talosctl'),
		dict(name="helm", versions=["v3.5.4"], repo="https://github.com/helm/helm", build="make", image="golang:latest", binary='bin/helm')
])
  
  steps = list()
  for item in data:
    for version in item["versions"]:
      steps.append(step(item, version))

  return steps

def step(data, version):
  return {
    "kind": "pipeline",
    "type": "kubernetes",
    "name": "build-%s-%s" % (data["name"], version),
    "steps": [
      {
        "name": "build",
        "image": data["image"],
        "commands": [
            "git clone --depth=1 --branch %s %s src" % (version, data["repo"]),
            "cd src",
            "%s" % data["build"],
        ]
      },
      {
        "name": "package",
        "image": "lib42/fpm:latest",
        "commands": [
          "mkdir -p out",
          "fpm -s dir -t deb -n %s -v %s -p out src/%s=/usr/bin/" % (data["name"], version, data["binary"]),
          "fpm -s dir -t rpm -n %s -v %s -p out src/%s=/usr/bin/" % (data["name"], version, data["binary"])
        ]
      },
			{
        "name": "upload",
        "image": "plugins/s3",
        "settings": {
          "bucket": "drone-bucket",
          "source": "out/*",
          "target": "/packages/",
          "path_style": True,
          "strip_prefix": True,
          "endpoint": "http://minio.minio.svc.cluster.local:9000",
          "access_key": {
             "from_secret": "access_key"
           },
          "secret_key": {
             "from_secret": "secret_key"
           }
			  }
      }
    ]
  }
