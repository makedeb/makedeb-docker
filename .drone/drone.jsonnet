local buildImage(type) = {
  name: "build-image-" + type,
  kind: "pipeline",
  type: "docker",
  trigger: {event: type},
  steps: [{
    name: "build-and-publish-" + type,
    image: "docker",
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
