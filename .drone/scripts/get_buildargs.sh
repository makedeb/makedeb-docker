# Function for getting build arguments.
# This accepts an item from a '_targets' array below, and returns the 'source_image'
# and docker_build_arguments variables, the first containing the image to build from
# and the second containing the tag arguments to pass to 'docker build'.
get_buildargs() {
  declare -g source_image \
             docker_build_arguments=()

  local target_tags

  source_image="$(echo "${1}" | awk -F '/' '{print $1}')"
  target_tags="$(echo "${1}" | awk -F '/' '{print $2}')"

  eval docker_build_tags=($(echo "${target_tags}" | \
                            sed -e "s|^|'|" \
                                -e "s|\$|'|" \
                                -e "s|,|' '|g"))

  # Define tags
  for i in "${docker_build_tags[@]}"; do
    docker_build_arguments+=("-t" "${proget_server}/docker/makedeb/makedeb:${TAG}-${i}")
  done
}
