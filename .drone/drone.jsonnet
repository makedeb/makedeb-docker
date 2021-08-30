local buildImage(type) = {
  name: "build-image",
  kind: "pipeline",
  type: "docker",
  trigger: {event: type},
  steps: [{
    name: "build-and-publish",
    image: "docker",
    environment: {

    },
    command: [
      "apk add --no-cache bash",
      ".drone/scripts/build_and_publish.sh"
    ]
  }]
};

[
  buildImage("cron"),
  buildImage("custom")
]
