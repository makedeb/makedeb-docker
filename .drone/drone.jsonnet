local buildImage(type) = {
  name: "build-image",
  kind: "pipeline",
  type: "docker",
  trigger: {event: type},
  steps: [{
    name: "build-and-publish",
    image: "docker",
    environment: {
      proget_api_key: {from_secret: "proget_api_key"}
    },
    commands: [
      "apk add --no-cache bash",
      ".drone/scripts/build_and_publish.sh"
    ]
  }]
};

[
  buildImage("cron"),
  buildImage("custom")
]
