#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex

if [[ "${CI_BUILD}" == "no" ]]; then
  exit 1
fi

tar -xzf ./vscode.tar.gz

./dev/set-vscode-release-version.sh

cd vscode || { echo "'vscode' dir not found"; exit 1; }

for i in {1..5}; do
  npm ci && break
  if [[ $i == 5 ]]; then
    echo "Npm install failed too many times" >&2
    exit 1
  fi
  echo "Npm install failed $i, trying again..."
done

node build/azure-pipelines/distro/mixin-npm.ts

# delete native files built in the `compile` step
find .build/extensions -type f -name '*.node' -print -delete

cd ..

if [[ -n "${RUNQL_CLIENT_VERSION}" ]] && [[ -n "${RUNQL_CLIENT_TARGET}" ]]; then
  ./dev/install-runql-client-release.sh "${RUNQL_CLIENT_VERSION}" "${RUNQL_CLIENT_TARGET}" vscode
fi

cd vscode || { echo "'vscode' dir not found"; exit 1; }

# generate Group Policy definitions
npm run copy-policy-dto --prefix build
node build/lib/policies/policyGenerator.ts build/lib/policies/policyData.jsonc darwin

npm run gulp "vscode-darwin-${VSCODE_ARCH}-min-ci"

if [[ -n "${RUNQL_CLIENT_VERSION}" ]] && [[ -n "${RUNQL_CLIENT_TARGET}" ]] && [[ ! -f "../VSCode-darwin-${VSCODE_ARCH}/${APP_NAME}.app/Contents/Resources/app/extensions/runql-client/package.json" ]]; then
  echo "Bundled RunQL client extension is missing from the macOS package" >&2
  exit 1
fi

find "../VSCode-darwin-${VSCODE_ARCH}" -print0 | xargs -0 touch -c

. ../build_cli.sh

if [[ "${SHOULD_BUILD_REH}" != "no" ]]; then
  npm run gulp minify-vscode-reh
  npm run gulp "vscode-reh-darwin-${VSCODE_ARCH}-min-ci"
fi

if [[ "${SHOULD_BUILD_REH_WEB}" != "no" ]]; then
  npm run gulp minify-vscode-reh-web
  npm run gulp "vscode-reh-web-darwin-${VSCODE_ARCH}-min-ci"
fi

cd ..
