should_fail () {
  if "$@"; then
    exit 1
  else
    true
  fi
}
