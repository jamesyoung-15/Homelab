#!/usr/bin/env bash

# Usage: tofu-env <environment> <tofu_command>
# Eg: tofu-env lab init

set -euo pipefail

environment="$1"
shift

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
terraform_dir="$repo_root/iac/terraform/${environment}"

cd "$terraform_dir"
exec "$repo_root/scripts/with-secrets.sh" "$environment" -- tofu "$@"
