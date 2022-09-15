#!/usr/bin/env bash
set -euo pipefail

base_dir="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
root_dir="$(dirname "$base_dir")"

cd "$root_dir"

npm run web-ext -- run -p aws-favicons --keep-profile-changes --reload -u 'https://us-west-2.console.aws.amazon.com/console/home?region=us-west-2#'
