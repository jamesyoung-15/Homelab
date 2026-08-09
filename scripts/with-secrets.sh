#!/usr/bin/env bash

# Usage: with-secrets.sh <environment> -- <command> [args...]
# Example: with-secrets.sh lab -- tofu plan

set -euo pipefail

if [[ $# -lt 2 ]]; then
  printf 'Usage: %s <environment> -- <command> [args...]\n' "$(basename "$0")" >&2
  exit 2
fi

environment="$1"
shift

if [[ "${1:-}" == "--" ]]; then
  shift
fi

if [[ $# -eq 0 ]]; then
  printf 'error: no command supplied\n' >&2
  exit 2
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$script_dir/.." && pwd)"
secrets_file="$repo_root/iac/secrets/${environment}.sops.yaml"

if [[ ! -f "$secrets_file" ]]; then
  printf 'error: secrets file not found: %s\n' "$secrets_file" >&2
  exit 1
fi

export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.sops/homelab-keys.txt}"
secrets="$(sops -d "$secrets_file")"

secret_value() {
  local expression="$1"
  printf '%s' "$secrets" | yq -r "${expression} // \"\""
}

export_if_set() {
  local name="$1"
  local value="$2"

  if [[ -n "$value" ]]; then
    export "$name=$value"
  fi
}

# OpenTofu provider variables.
export_if_set TF_VAR_proxmox_endpoint "$(secret_value '.proxmox.endpoint')"
export_if_set TF_VAR_proxmox_token_id "$(secret_value '.proxmox.token_id')"
export_if_set TF_VAR_proxmox_token_secret "$(secret_value '.proxmox.token_secret')"
export_if_set TF_VAR_cloudflare_account_id "$(secret_value '.cloudflare.account_id')"
export_if_set TF_VAR_cloudflare_api_token "$(secret_value '.cloudflare.api_token')"

# The S3-compatible R2 backend reads these standard AWS variable names.
export_if_set TF_VAR_cloudflare_r2_bucket "$(secret_value '.cloudflare.r2.bucket')"
export_if_set AWS_ACCESS_KEY_ID "$(secret_value '.cloudflare.r2.access_key_id')"
export_if_set AWS_SECRET_ACCESS_KEY "$(secret_value '.cloudflare.r2.secret_access_key')"

exec "$@"
