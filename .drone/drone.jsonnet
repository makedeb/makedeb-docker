local buildImage(type) = {
  name: "build-image-" + type,
  kind: "pipeline",
  type: "docker",
  trigger: {event: type},
  volumes: [{name: "docker", host: {path: "/var/run/docker.sock"}}],
  steps: [{
    name: "build-and-publish-" + type,
    image: "docker",
    volumes: [{name: "docker", path: "/var/run/docker.sock"}],
    environment: {
      proget_api_key: {from_secret: "proget_api_key"},
      TAG: "stable"
    },
    commands: [
      "apk add --no-cache bash",
      ".drone/scripts/main.sh"
    ]
  }]
};

[
  buildImage("cron"),
  buildImage("custom"),
  buildImage("push")
]
