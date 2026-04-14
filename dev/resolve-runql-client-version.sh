#!/usr/bin/env bash

set -euo pipefail

CURRENT_VERSION="${RUNQL_CLIENT_VERSION:-}"
RUNQL_CLIENT_REPO="${RUNQL_CLIENT_REPO:-DVCodeLabs/RunQL}"
GH_HOST="${GH_HOST:-github.com}"

if [[ -n "${CURRENT_VERSION}" ]]; then
  RESOLVED_VERSION="${CURRENT_VERSION#v}"
  echo "Using provided RunQL extension version: ${RESOLVED_VERSION}"
else
  if [[ -z "${GH_TOKEN:-}" ]] && [[ -z "${GITHUB_TOKEN:-}" ]] && [[ -z "${GH_ENTERPRISE_TOKEN:-}" ]] && [[ -z "${GITHUB_ENTERPRISE_TOKEN:-}" ]]; then
    echo "No GitHub token available to resolve the latest RunQL extension release" >&2
    exit 1
  fi

  TOKEN="${GH_TOKEN:-${GITHUB_TOKEN:-${GH_ENTERPRISE_TOKEN:-${GITHUB_ENTERPRISE_TOKEN:-}}}}"
  API_URL="https://api.${GH_HOST}/repos/${RUNQL_CLIENT_REPO}/releases/latest"

  RESPONSE="$(curl -fsSL -H "Authorization: token ${TOKEN}" "${API_URL}")"
  TAG_NAME="$(echo "${RESPONSE}" | jq -r '.tag_name')"

  if [[ -z "${TAG_NAME}" || "${TAG_NAME}" == "null" ]]; then
    echo "Could not determine latest RunQL extension release tag from ${RUNQL_CLIENT_REPO}" >&2
    exit 1
  fi

  RESOLVED_VERSION="${TAG_NAME#v}"
  echo "Resolved latest RunQL extension version: ${RESOLVED_VERSION}"
fi

if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "RUNQL_CLIENT_VERSION=${RESOLVED_VERSION}" >> "${GITHUB_ENV}"
fi

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "runql_client_version=${RESOLVED_VERSION}" >> "${GITHUB_OUTPUT}"
fi

echo "${RESOLVED_VERSION}"
