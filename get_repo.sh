#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

normalize_runql_client_version() {
  echo "${1#v}"
}

encode_runql_client_version() {
  local version="$1"

  if [[ ! "${version}" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "Error: Bad RUNQL_CLIENT_VERSION: ${version}" >&2
    exit 1
  fi

  printf "%02d%02d%02d" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
}

# Derive a proper 4-part installer version (major.minor.build.revision) from
# the encoded RELEASE_VERSION. This is the form fed to platform installers that
# strictly validate Version parsing (MSI candle.exe, Inno Setup RawVersion,
# update-check productVersion). Each component fits in Int32/UInt16.
#
# RELEASE_VERSION scheme: ${MS_MAJOR}.${MS_MINOR}.${MS_PATCH}${TIME_PATCH_4}${RUNQL_SUFFIX_6}[-insider]
# e.g. 1.112.02539010502 -> 1.112.2539.10502
compute_installer_version() {
  local release_version="${1%-insider}"

  if [[ "${release_version}" =~ ^([0-9]+)\.([0-9]+)\.[0-9]([0-9]{4})([0-9]{6})$ ]]; then
    printf "%d.%d.%d.%d" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "$((10#${BASH_REMATCH[3]}))" "$((10#${BASH_REMATCH[4]}))"
  elif [[ "${release_version}" =~ ^([0-9]+)\.([0-9]+)\.[0-9]([0-9]{4})$ ]]; then
    printf "%d.%d.%d.0" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "$((10#${BASH_REMATCH[3]}))"
  elif [[ "${release_version}" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    printf "%d.%d.%d.0" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "$((10#${BASH_REMATCH[3]}))"
  else
    echo "Error: Unable to derive INSTALLER_VERSION from RELEASE_VERSION: ${1}" >&2
    exit 1
  fi
}

if [[ -z "${RUNQL_CLIENT_VERSION}" ]] && [[ -n "${RUNQL_CLIENT_TAG}" ]]; then
  RUNQL_CLIENT_VERSION="$(normalize_runql_client_version "${RUNQL_CLIENT_TAG}")"
fi

RUNQL_CLIENT_SUFFIX=""

if [[ -n "${RUNQL_CLIENT_VERSION}" ]]; then
  RUNQL_CLIENT_SUFFIX="$(encode_runql_client_version "${RUNQL_CLIENT_VERSION}")"
fi

# git workaround
if [[ "${CI_BUILD}" != "no" ]]; then
  git config --global --add safe.directory "/__w/$( echo "${GITHUB_REPOSITORY}" | awk '{print tolower($0)}' )"
fi

if [[ -z "${RELEASE_VERSION}" ]]; then
  if [[ "${VSCODE_LATEST}" == "yes" ]] || [[ ! -f "./upstream/${VSCODE_QUALITY}.json" ]]; then
    echo "Retrieve lastest version"
    UPDATE_INFO=$( curl --silent --fail "https://update.code.visualstudio.com/api/update/darwin/${VSCODE_QUALITY}/0000000000000000000000000000000000000000" )
  else
    echo "Get version from ${VSCODE_QUALITY}.json"
    MS_COMMIT=$( jq -r '.commit' "./upstream/${VSCODE_QUALITY}.json" )
    MS_TAG=$( jq -r '.tag' "./upstream/${VSCODE_QUALITY}.json" )
  fi

  if [[ -z "${MS_COMMIT}" ]]; then
    MS_COMMIT=$( echo "${UPDATE_INFO}" | jq -r '.version' )
    MS_TAG=$( echo "${UPDATE_INFO}" | jq -r '.name' )

    if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
      MS_TAG="${MS_TAG/\-insider/}"
    fi
  fi

  TIME_PATCH=$( printf "%04d" $(($(date +%-j) * 24 + $(date +%-H))) )

  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    BASE_RELEASE_VERSION="${MS_TAG}${TIME_PATCH}"
    RELEASE_VERSION="${BASE_RELEASE_VERSION}-insider"
  else
    BASE_RELEASE_VERSION="${MS_TAG}${TIME_PATCH}"
    RELEASE_VERSION="${BASE_RELEASE_VERSION}${RUNQL_CLIENT_SUFFIX}"
  fi
else
  if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
    if [[ "${RELEASE_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-5])[0-9]+-insider$ ]];
    then
      MS_TAG="${BASH_REMATCH[1]}"
      BASE_RELEASE_VERSION="${RELEASE_VERSION%-insider}"
    else
      echo "Error: Bad RELEASE_VERSION: ${RELEASE_VERSION}"
      exit 1
    fi
  else
    if [[ "${RELEASE_VERSION}" =~ ^([0-9]+\.[0-9]+\.[0-5])[0-9]+$ ]];
    then
      MS_TAG="${BASH_REMATCH[1]}"
      BASE_RELEASE_VERSION="${RELEASE_VERSION}"

      if [[ -n "${RUNQL_CLIENT_SUFFIX}" ]] && [[ "${BASE_RELEASE_VERSION}" == *"${RUNQL_CLIENT_SUFFIX}" ]]; then
        BASE_RELEASE_VERSION="${BASE_RELEASE_VERSION%${RUNQL_CLIENT_SUFFIX}}"
      fi
    else
      echo "Error: Bad RELEASE_VERSION: ${RELEASE_VERSION}"
      exit 1
    fi
  fi

  if [[ "${MS_TAG}" == "$( jq -r '.tag' "./upstream/${VSCODE_QUALITY}.json" )" ]]; then
    MS_COMMIT=$( jq -r '.commit' "./upstream/${VSCODE_QUALITY}.json" )
  else
    echo "Error: No MS_COMMIT for ${RELEASE_VERSION}"
    exit 1
  fi
fi

INSTALLER_VERSION=$( compute_installer_version "${RELEASE_VERSION}" )

echo "RELEASE_VERSION=\"${RELEASE_VERSION}\""
echo "INSTALLER_VERSION=\"${INSTALLER_VERSION}\""

mkdir -p vscode
cd vscode || { echo "'vscode' dir not found"; exit 1; }

git init -q
git remote add origin https://github.com/Microsoft/vscode.git

# figure out latest tag by calling MS update API
if [[ -z "${MS_TAG}" ]]; then
  UPDATE_INFO=$( curl --silent --fail "https://update.code.visualstudio.com/api/update/darwin/${VSCODE_QUALITY}/0000000000000000000000000000000000000000" )
  MS_COMMIT=$( echo "${UPDATE_INFO}" | jq -r '.version' )
  MS_TAG=$( echo "${UPDATE_INFO}" | jq -r '.name' )
elif [[ -z "${MS_COMMIT}" ]]; then
  REFERENCE=$( git ls-remote --tags | grep -x ".*refs\/tags\/${MS_TAG}" | head -1 )

  if [[ -z "${REFERENCE}" ]]; then
    echo "Error: The following tag can't be found: ${MS_TAG}"
    exit 1
  elif [[ "${REFERENCE}" =~ ^([[:alnum:]]+)[[:space:]]+refs\/tags\/([0-9]+\.[0-9]+\.[0-5])$ ]]; then
    MS_COMMIT="${BASH_REMATCH[1]}"
    MS_TAG="${BASH_REMATCH[2]}"
  else
    echo "Error: The following reference can't be parsed: ${REFERENCE}"
    exit 1
  fi
fi

echo "MS_TAG=\"${MS_TAG}\""
echo "MS_COMMIT=\"${MS_COMMIT}\""

git fetch --depth 1 origin "${MS_COMMIT}"
git checkout FETCH_HEAD

cd ..

# for GH actions
if [[ "${GITHUB_ENV}" ]]; then
  echo "BASE_RELEASE_VERSION=${BASE_RELEASE_VERSION}" >> "${GITHUB_ENV}"
  echo "INSTALLER_VERSION=${INSTALLER_VERSION}" >> "${GITHUB_ENV}"
  echo "MS_TAG=${MS_TAG}" >> "${GITHUB_ENV}"
  echo "MS_COMMIT=${MS_COMMIT}" >> "${GITHUB_ENV}"
  echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"
  echo "RUNQL_CLIENT_TAG=${RUNQL_CLIENT_TAG}" >> "${GITHUB_ENV}"
  echo "RUNQL_CLIENT_VERSION=${RUNQL_CLIENT_VERSION}" >> "${GITHUB_ENV}"
fi

export BASE_RELEASE_VERSION
export INSTALLER_VERSION
export MS_TAG
export MS_COMMIT
export RELEASE_VERSION
export RUNQL_CLIENT_TAG
export RUNQL_CLIENT_VERSION
