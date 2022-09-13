#!/usr/bin/env bash
set -euo pipefail

basedir="$(dirname "${BASH_SOURCE[0]}")"
services_file="$basedir/services.json"
icons_dir="$basedir/icons"

cookie="${1:?usage: $0 <aws console cookie>}"

cd "$basedir"

res="$(curl -fL 'https://us-west-2.console.aws.amazon.com/console/home?region=us-west-2' -H "Cookie: $cookie")"
mezz="$(pup -p 'meta[name=awsc-mezz-data] attr{content}' <<<"$res" | jq)"
icon_domain="$(pup -p 'meta[name=icon-domain] attr{content}' <<<"$res")"

if [[ -z "$mezz" || -z "$icon_domain" ]]; then
  echo "Failed to fetch AWS Console homepage. Check to ensure your cookie is valid."
  exit 1
fi

# shellcheck disable=2016
node -e '
  const { awsBaseURL } = require("./index.js");
  const { readFileSync } = require("fs");
  const iconDomain = process.argv.at(-1)
  const input = readFileSync(0, "utf-8");
  const json = JSON.parse(input);
  const res = json.services.reduce((acc, s) => (s.icon ? { ...acc, [awsBaseURL(s.url)]: { icon: s.icon, id: s.id } } : acc), {});
  process.stdout.write(JSON.stringify(res));
  ' -- "$icon_domain" <<<"$mezz" | jq >"$services_file"

echo "Updated $(basename "$services_file")"

rm -vrf "$icons_dir"
mkdir "$icons_dir"

i=0
n="$(jq -r 'length' "$services_file")"

while read -r id; do
  i=$((i + 1))
  read -r icon
  printf '%4s/%s - %s\n' "$i" "$n" "$id"
  curl --no-progress-meter "$icon_domain/$icon" >"$icons_dir/$id.svg"
  # convert "$icons_dir/$id.svg" "$icons_dir/$id.ico"
done <<<"$(jq -r 'map(.id, .icon) | .[]' "$services_file")"

echo "Updated icons"
