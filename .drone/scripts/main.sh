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
  stable)     makedeb_package="makedeb"; makepkg_package="makedeb-makepkg"; target_tag="${proget_server}/docker/makedeb/makedeb:${target_tag}";;
  beta|alpha) makedeb_package="makedeb-${TAG}"; makepkg_package="makedeb-makepkg-${TAG}"; target_tag="${proget_server}/docker/makedeb/makedeb:${target_tag}-${TAG}" ;;
  "")         echo "[Error] No tag was specified."; exit 1 ;;
  *)          echo "[Error] Invalid tag '${TAG}'."; exit 1 ;;
esac

# Setup image.
echo "[Info] Building 'makedeb/makedeb:${target_tag}' from '${source_image}'..."

if [[ "${os_type}" == "debian" ]]; then
  target_dockerfile="Dockerfile.debian"
elif [[ "${os_type}" == "archlinux" ]]; then
  target_dockerfile="Dockerfile.archlinux"
else
  echo "Invalid os type was passed."
fi

sed -i "1s|{{image}}|${source_image}|" "./${target_dockerfile}"

# Build and publish image.
docker build --no-cache \
             -t "${target_tag}" \
             -f "./${target_dockerfile}" \
             ./

docker push "${target_tag}"
