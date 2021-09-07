#!/usr/bin/env bash
set -e

# NOTE: This script needs to be ran from the root of the makedeb-docker
# repository to function correctly.

# Source functions
for i in "get_buildargs" "run_verbosely" "configure_docker"; do
  source ".drone/scripts/${i}.sh"
done

# Log in to ProGet server.
configure_docker

# Define images to build.
# These take the syntax of 'image/target_tag' where 'image' is an image name
# (with optional tag), and 'target_tag' is a comma-separated list of tag suffixes
#  to publish under (they all get prefixed with the release name such as 'beta_').
debian_targets=("debian:latest/debian-latest"
                "debian:buster/debian-buster"
                "debian:bullseye/debian-bullseye"
                "ubuntu:latest/ubuntu-latest"
                "ubuntu:rolling/ubuntu-rolling"
                "ubuntu:bionic/ubuntu-bionic"
                "ubuntu:focal/ubuntu-focal")

arch_targets=("archlinux/archlinux-latest")

# Ensure tag was specified.
case "${TAG}" in
  stable)     makedeb_package="makedeb"; makepkg_package="makedeb-makepkg" ;;
  beta|alpha) makedeb_package="makedeb-${TAG}"; makepkg_package="makedeb-makepkg-${TAG}" ;;
  "")         echo "[Error] No tag was specified."; exit 1 ;;
  *)          echo "[Error] Invalid tag '${TAG}'."; exit 1 ;;
esac

# Build images.
echo "[Info] Building images..."

built_image_tags=()

# Build Debian images.
for i in "${debian_targets[@]}"; do

  # We get 'source_image' and 'docker_build_arguments' from this function.
  get_buildargs "${i}"

  # Add tags to separate array so we know what tags to upload later.
  for j in "${docker_build_arguments[@]}"; do
    if [[ "${j}" != "-t" ]]; then
      built_image_tags+=("${j}")
    fi
  done

    rm -rf Dockerfile.debian.tmp
    cp Dockerfile.debian Dockerfile.debian.tmp

    sed -i "s|{{image}}|${source_image}|" Dockerfile.debian.tmp

    # Formatted tags.
    formatted_target_tags="$(echo "${docker_build_arguments[@]}" | sed "s|-t ||g")"

  # Build images.
  echo "[Info] Building image for '${source_image}' with tags ${formatted_target_tags}."
  run_verbosely docker build ./ \
                       -f ./Dockerfile.debian.tmp \
                       "${docker_build_arguments[@]}" \
                       --build-arg "proget_url=${proget_server}" \
                       --build-arg "makedeb_package=${makedeb_package}"
done

# Build Arch Linux images.
for i in "${arch_targets[@]}"; do
  get_buildargs "${i}"

  # Add tags to separate array so we know what tags to upload later.
  for j in "${docker_build_arguments[@]}"; do
    if [[ "${j}" != "-t" ]]; then
      built_image_tags+=("${j}")
    fi
  done

  rm -rf Dockerfile.archlinux.tmp
  cp Dockerfile.archlinux Dockerfile.archlinux.tmp

  sed -i "s|{{image}}|${source_image}|" Dockerfile.archlinux.tmp

  # Formatted tags.
  formatted_target_tags="$(echo "${docker_build_arguments[@]}" | sed "s|-t ||g")"

  # Build images.
  echo "[Info] Building image for '${source_image}' with tags ${formatted_target_tags}."
  run_verbosely docker build ./ \
                       -f ./Dockerfile.archlinux.tmp \
                       "${docker_build_arguments[@]}" \
                       --build-arg "aur_url=${aur_url}" \
                       --build-arg "makedeb_package=${makedeb_package}" \
                       --build-arg "makepkg_package=${makepkg_package}"
done

# Remove temporary Dockerfiles.
rm Dockerfile.debian.tmp \
   Dockerfile.archlinux.tmp

# Upload all the of the built images.
for i in "${built_image_tags[@]}"; do
  run_verbosely docker push -- "${i}"
done
