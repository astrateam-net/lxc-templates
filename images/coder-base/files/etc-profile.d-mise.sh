# shellcheck shell=sh
if [ -n "${PS1:-}" ] && command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
