def main(ctx):
  data = list([
		dict(name="talosctl", versions=["v0.9.1", "v0.10.1"], repo="https://github.com/talos-systems/talos", build="cd cmd/talosctl ; go build", image="golang:latest", binary='src/cmd/talosctl/talosctl')
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
      }
    ]
  }
