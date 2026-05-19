#!/bin/bash

# Centralized Docker service name resolution
# Used by both bash aliases (de, deit) and Neovim test runner

get_docker_service() {
  local cwd="${1:-$PWD}"
  local dir_name=$(basename "$cwd")

  # Take the name before the first hyphen
  # e.g. assessor-rails -> assessor, account-fw1 -> account, account -> account
  local service_name="${dir_name%%-*}"

  # Return service name for docker compose (with -web suffix)
  echo "${service_name}-web"
}

# If script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  get_docker_service "$@"
fi
