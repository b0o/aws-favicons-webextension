#!/usr/bin/env bash
set -euo pipefail

base_dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
root_dir="$(dirname "$base_dir")"

new_version="${1:?usage: $0 <new_semver|major|minor|patch>}"

if ! [[ "$new_version" =~ ^(major|minor|patch)$ || "$new_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "'$new_version' is not a valid semver"
  exit 1
fi

function update_version() {
  file="$1"
  cur_file="$(cat "$file")"
  cur_version="$(jq <<<"$cur_file" -r '.version')"
  if [[ "$new_version" =~ ^(major|minor|patch)$ ]]; then
    op=""
    # shellcheck disable=2016
    case "$new_version" in
    major) op='print $1 + 1 ".0.0" ' ;;
    minor) op='print $1 "." $2 + 1 ".0" ' ;;
    patch) op='print $1 "." $2 "." $3 + 1' ;;
    esac
    new_version="$(awk <<<"$cur_version" -F '.' "{ $op }")"
  fi
  # shellcheck disable=2094
  jq <<<"$cur_file" -r --arg new_version "$new_version" '.version = $new_version' |
    prettier --stdin-filepath "$file" >"$file"
  echo "$file $cur_version -> $new_version"
}

update_version "$root_dir/package.json"
update_version "$root_dir/package-lock.json"
update_version "$root_dir/manifest.v2.json"
update_version "$root_dir/manifest.v3.json"
