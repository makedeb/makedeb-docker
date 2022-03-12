#!/usr/bin/env bash
set -ex

# Log in to the ProGet instance.
echo "${proget_api_key}" | docker login -u api --password-stdin "proget.${hw_url}"

# Build the specified image for each makedeb release.
tag="${image//:/-}"

for release in 'makedeb' 'makedeb-beta' 'makedeb-alpha'; do
    cp Dockerfile Dockerfile.tmp
    sed -i "s|{{ image }}|${image}|" Dockerfile.tmp

    docker build --no-cache \
                 --pull \
                 -t "proget.${hw_url}/${release}:${tag}" \
                 -f ./Dockerfile.tmp \
                 --build-arg "proget_url=${proget_url}" \
                 --build-arg "makedeb_package=${release}" \
                 ./

    docker push "proget.${hw_url}/${release}:${tag}"
done

# vim: set sw=4 expandtab:
