local buildImage(source_image, target_tag) = {
  name: "build-image-" + target_tag,
  kind: "pipeline",
  type: "docker",
  volumes: [{name: "docker", host: {path: "/var/run/docker.sock"}}],
  steps: [{
    name: "build-and-publish-" + target_tag,
    image: "docker",
    volumes: [{name: "docker", path: "/var/run/docker.sock"}],
    environment: {
      proget_api_key: {from_secret: "proget_api_key"},
      source_image: source_image,
      target_tag: target_tag
    },
    commands: [
      "apk add --no-cache bash",
      ".drone/scripts/main.sh"
    ]
  }]
};

[
  buildImage("debian:latest", "debian-latest"),
  buildImage("debian:buster", "debian-buster"),
  buildImage("debian:bullseye", "debian-bullseye"),
  buildImage("ubuntu:latest", "ubuntu-latest"),
  buildImage("ubuntu:rolling", "ubuntu-rolling"),
  buildImage("ubuntu:bionic", "ubuntu-bionic"),
  buildImage("ubuntu:focal", "ubuntu-focal"),
]
