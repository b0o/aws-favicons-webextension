#!/usr/bin/env bash
set -euo pipefail

basedir="$(dirname "${BASH_SOURCE[0]}")"
services_file="$basedir/services.json"
icons_dir="$basedir/icons"

function usage() {
  echo "usage: $0 <console_url> <-H curl_header> [-H curl_header ..]"
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

node -e '
    const { awsBaseURL } = require("./index.js");
    const { readFileSync } = require("fs");
    const input = readFileSync(0, "utf-8");
    const res = JSON.parse(input).services
      .reduce((acc, s) => (s.icon ? { ...acc, [awsBaseURL(s.url)]: { icon: s.icon, id: s.id } } : acc), {});
    process.stdout.write(JSON.stringify(res));
  ' <<<"$mezz" | jq >"$services_file"

echo "Updated $(basename "$services_file")"

rm -vrf "$icons_dir"
mkdir "$icons_dir"

i=0
n="$(jq -r 'length' "$services_file")"
while read -r id; do
  read -r icon
  i=$((i + 1))
  printf '%4s/%s - %s\n' "$i" "$n" "$id"
  curl --no-progress-meter "$icon_domain/$icon" >"$icons_dir/$id.svg"
done <<<"$(jq -r 'map(.id, .icon) | .[]' "$services_file")"

echo "Updated icons"
