#!/bin/bash

# Centralized Docker service name resolution
# Used by both bash aliases (de, deit) and Neovim test runner

get_docker_service() {
  local cwd="${1:-$PWD}"
  local dir_name=$(basename "$cwd")

  # Special case: assessor-rails maps to assessor
  if [[ "$dir_name" == "assessor-rails" ]]; then
    service_name="assessor"
  else
    # Default: use directory basename as-is
    service_name="$dir_name"
  fi

  # Return full container name: app-{service}-web-1
  echo "app-${service_name}-web-1"
}

# If script is executed directly (not sourced), run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  get_docker_service "$@"
fi
