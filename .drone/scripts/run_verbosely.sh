run_verbosely() {
  set -x
  "${@}"
  set +x
}
