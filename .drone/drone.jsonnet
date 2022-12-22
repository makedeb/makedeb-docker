local buildImage(image, pipeline_name) = {
  name: "build-image-" + pipeline_name,
  kind: "pipeline",
  type: "docker",
  trigger: {branch: ["master"]},
  volumes: [{name: "docker", host: {path: "/var/run/docker.sock"}}],
  steps: [{
    name: "build-and-publish-" + pipeline_name,
    image: "docker",
    volumes: [{name: "docker", path: "/var/run/docker.sock"}],
    environment: {
      proget_api_key: {from_secret: "proget_api_key"},
      image: image
    },
    commands: [
      "apk add --no-cache bash",
      ".drone/scripts/build_and_publish.sh"
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
  buildImage("ubuntu:jammy", "ubuntu-jammy"),
  buildImage("ubuntu:kinetic", "ubuntu-kinetic"),
]
