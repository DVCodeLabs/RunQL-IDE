#!/usr/bin/env bash

if [ -n "${ZSH_VERSION:-}" ]; then
  _runql_macos_env_source="${(%):-%x}"
else
  _runql_macos_env_source="${BASH_SOURCE[0]}"
fi

_runql_macos_env_dir="$(cd "$(dirname "${_runql_macos_env_source}")" && pwd)"
_runql_nvmrc_path="${_runql_macos_env_dir}/../.nvmrc"

if command -v python3.11 >/dev/null 2>&1; then
  export PATH="$(dirname "$(command -v python3.11)"):$PATH"
  export npm_config_python="$(command -v python3.11)"
elif command -v python3 >/dev/null 2>&1; then
  export npm_config_python="$(command -v python3)"
fi

if [ -d "${HOME}/.cargo/bin" ]; then
  export PATH="${HOME}/.cargo/bin:${PATH}"
fi

if command -v asdf >/dev/null 2>&1 && [ -f "${_runql_nvmrc_path}" ]; then
  asdf shell nodejs "$(tr -d '[:space:]' < "${_runql_nvmrc_path}")" >/dev/null 2>&1 || true
fi
