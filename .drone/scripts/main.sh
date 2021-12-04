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


# Ensure tag was specified.
case "${TAG}" in
  stable)     package=("makedeb");;
  beta|alpha) package=("makedeb-${TAG}");;
  "")         package=("makedeb" "makedeb-beta" "makedeb-alpha");;
  *)          echo "[Error] Invalid tag '${TAG}'."; exit 1 ;;
esac

# Setup image.
for i in "${package[@]}"; do
  echo "[Info] Building 'makedeb/${i}:${target_tag}' from '${source_image}'..."

  if [[ "${os_type}" == "debian" ]]; then
    target_dockerfile="Dockerfile.debian"
  elif [[ "${os_type}" == "archlinux" ]]; then
    target_dockerfile="Dockerfile.archlinux"
  else
    echo "Invalid os type was passed."
  fi

  sed -i "1s|{{image}}|${source_image}|" "./${target_dockerfile}"

  published_image_path="${proget_server}/docker/makedeb/${i}:${target_tag}"

  # Build and publish image.
  docker build --no-cache \
               --pull \
               -t "${published_image_path}" \
               -f "./${target_dockerfile}" \
               --build-arg "proget_url=${proget_server}" \
               --build-arg "aur_url=${aur_url}" \
               --build-arg "makedeb_package=${i}" \
               ./

  docker push "${published_image_path}"
done
