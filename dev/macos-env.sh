#!/usr/bin/env bash

if command -v python3.11 >/dev/null 2>&1; then
  export PATH="$(dirname "$(command -v python3.11)"):$PATH"
  export npm_config_python="$(command -v python3.11)"
elif command -v python3 >/dev/null 2>&1; then
  export npm_config_python="$(command -v python3)"
fi

if [ -d "${HOME}/.cargo/bin" ]; then
  export PATH="${HOME}/.cargo/bin:${PATH}"
fi

if command -v asdf >/dev/null 2>&1; then
  asdf shell nodejs "$(cat "$(dirname "${BASH_SOURCE[0]}")/../.nvmrc")" >/dev/null 2>&1 || true
fi
