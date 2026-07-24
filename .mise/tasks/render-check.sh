#!/usr/bin/env bash
#MISE description="Re-render every image; fail if the committed definition drifted or is invalid"
set -eo pipefail

shopt -s nullglob
outs=()
for tpl in images/*/manifest.yaml.tpl; do
  img="$(basename "$(dirname "$tpl")")"
  mise run render "$img" >/dev/null
  yq '.' "images/$img/$img.yaml" >/dev/null
  outs+=("images/$img/$img.yaml")
done
[ "${#outs[@]}" -gt 0 ] || { echo "no images found" >&2; exit 1; }

if [ -n "$(git ls-files --others --exclude-standard -- "${outs[@]}")" ] || ! git diff --quiet -- "${outs[@]}"; then
  echo "drift: run 'mise run render <image>' and commit the result" >&2
  exit 1
fi
