configure_docker() {
  echo "[Info] Logging in to ProGet server..."

  echo "${proget_api_key}" | \
  docker login --username "api" \
               --password-stdin \
               "https://${proget_url}/"
}
