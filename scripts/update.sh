#!/usr/bin/env bash
# TODO: Migrate this script to JS
set -euo pipefail

base_dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
root_dir="$(dirname "$base_dir")"
services_file="$root_dir/services.json"
icons_dir="$root_dir/icons"

function usage() {
  echo "usage: $0 <aws_console_url> <-H curl_header> [-H curl_header ..]"
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

url="$1"
shift

host="$(sed -n 's|^https://\([^/]*\)\(/.*\)\?$|\1|p' <<<"$url")"
if [[ -z "$host" ]]; then
  echo "unable to determine host"
  exit 1
fi

region="$(sed <<<"$host" -n 's/\(.*\.\)*\([^.]\+\)\.console\.aws\.amazon\.com$/\2/ip')"
if [[ -z "$region" ]]; then
  echo "unable to determine region from headers"
  exit 1
fi

curl_args=()
while [[ $# -gt 0 ]]; do
  if [[ $# -lt 2 ]]; then
    usage
    exit 1
  fi
  flag="$1"
  shift
  arg="$1"
  shift
  if [[ "$flag" != "-H" || "$arg" =~ ^(Accept|Connection) ]]; then
    continue
  fi
  curl_args+=(-H "$arg")
done

res="$(curl -fL "https://${region}.console.aws.amazon.com/console/home?region=${region}#" "${curl_args[@]}")"
mezz="$(pup -p 'meta[name=awsc-mezz-data] attr{content}' <<<"$res" | jq)"
icon_domain="$(pup -p 'meta[name=icon-domain] attr{content}' <<<"$res")"

if [[ -z "$mezz" || -z "$icon_domain" ]]; then
  echo "Failed to fetch AWS Console homepage. Check to ensure your cookie is valid."
  exit 1
fi

node "$base_dir/update.js" <<<"$mezz" | jq >"$services_file"

mkdir -p "$icons_dir"
find "$icons_dir" -maxdepth 1 -mindepth 1 -type f -iregex '.*\.\(png\|svg\|jpg\)' -exec rm -v '{}' ';'

i=0
n="$(jq -r 'length' "$services_file")"
while read -r id; do
  read -r icon
  i=$((i + 1))
  printf '%4s/%s - %s\n' "$i" "$n" "$id"
  curl --no-progress-meter "$icon_domain/$icon" >"$icons_dir/$id.svg"
done <<<"$(jq -r 'map(.id, .icon) | .[]' "$services_file")"
