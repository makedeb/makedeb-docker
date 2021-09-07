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
  stable)     makedeb_package="makedeb"; makepkg_package="makedeb-makepkg" ;;
  beta|alpha) makedeb_package="makedeb-${TAG}"; makepkg_package="makedeb-makepkg-${TAG}" ;;
  "")         echo "[Error] No tag was specified."; exit 1 ;;
  *)          echo "[Error] Invalid tag '${TAG}'."; exit 1 ;;
esac

# Setup image.
echo "[Info] Building 'makedeb/${makedeb_package}:${target_tag}' from '${source_image}'..."

if [[ "${os_type}" == "debian" ]]; then
  target_dockerfile="Dockerfile.debian"
elif [[ "${os_type}" == "archlinux" ]]; then
  target_dockerfile="Dockerfile.archlinux"
else
  echo "Invalid os type was passed."
fi

sed -i "1s|{{image}}|${source_image}|" "./${target_dockerfile}"

published_image_path="${proget_server}/docker/makedeb/${makedeb_package}:${target_tag}"

# Build and publish image.
docker build --no-cache \
             -t "${published_image_path}" \
             -f "./${target_dockerfile}" \
             --build-arg "proget_url=${proget_server}" \
             --build-arg "aur_url=${aur_url}" \
             --build-arg "makedeb_package=${makedeb_package}" \
             --build-arg "makepkg_package=${makepkg_package}" \
             ./

docker push "${published_image_path}"
