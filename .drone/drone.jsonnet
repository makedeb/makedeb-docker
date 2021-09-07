local buildImage(source_image, target_tag, os_type) = {
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
      TAG: "stable",
      source_image: source_image,
      target_tag: target_tag,
      os_type: os_type
    },
    commands: [
      "apk add --no-cache bash",
      ".drone/scripts/main.sh"
    ]
  }]
};

[
  buildImage("debian:latest", "debian-latest", "debian"),
  buildImage("debian:buster", "debian-buster", "debian"),
  buildImage("debian:bullseye", "debian-bullseye", "debian"),
  buildImage("ubuntu:latest", "ubuntu-latest", "debian"),
  buildImage("ubuntu:rolling", "ubuntu-rolling", "debian"),
  buildImage("ubuntu:bionic", "ubuntu-bionic", "debian"),
  buildImage("ubuntu:focal", "ubuntu-focal", "debian"),

  buildImage("archlinux", "archlinux-latest", "archlinux")
]
