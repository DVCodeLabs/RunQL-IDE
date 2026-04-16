#!/usr/bin/env bash

set -ex

CALLER_DIR=$( pwd )

cd "$( dirname "${BASH_SOURCE[0]}" )"

WIN_SDK_MAJOR_VERSION="10"
WIN_SDK_FULL_VERSION="10.0.17763.0"

if [[ -z "${APP_NAME}" ]]; then
  echo "Error: APP_NAME is not set. Ensure the workflow env defines it."
  exit 1
fi

# Actual Windows executable basename, read from the merged product.json.
# prepare_vscode.sh writes the final product.json under vscode/, which is where
# gulp reads nameShort from to name the executable. We are currently cd'd into
# build/windows/msi, so vscode/product.json is three levels up.
WIN_EXE_NAME="$( node -p "require(\"../../../vscode/product.json\").nameShort" )"

if [[ -z "${WIN_EXE_NAME}" || "${WIN_EXE_NAME}" == "undefined" ]]; then
  echo "Error: could not read nameShort from ../../../vscode/product.json"
  exit 1
fi

# Sanitize APP_NAME for use as a WiX identifier (stripped to alphanumerics).
APP_NAME_CODE="${APP_NAME//[^A-Za-z0-9]/}"

if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  PRODUCT_NAME="${APP_NAME} - Insiders"
  PRODUCT_CODE="${APP_NAME_CODE}Insiders"
  # RunQL insider upgrade code — distinct from upstream VSCodium-insiders to avoid
  # MSI UpgradeCode collisions if both are ever installed on the same machine.
  PRODUCT_UPGRADE_CODE="961BC5CC-9F56-49F8-A95F-0E3726C1CBD7"
  ICON_DIR="..\\..\\..\\src\\insider\\resources\\win32"
  SETUP_RESOURCES_DIR=".\\resources\\insider"
else
  PRODUCT_NAME="${APP_NAME}"
  PRODUCT_CODE="${APP_NAME_CODE}"
  # RunQL stable upgrade code — distinct from upstream VSCodium's to avoid
  # MSI UpgradeCode collisions if both are ever installed on the same machine.
  PRODUCT_UPGRADE_CODE="7945326F-FE6A-4A71-803F-F4FE5354B5DF"
  ICON_DIR="..\\..\\..\\src\\stable\\resources\\win32"
  SETUP_RESOURCES_DIR=".\\resources\\stable"
fi

PRODUCT_ID=$( powershell.exe -command "[guid]::NewGuid().ToString().ToUpper()" )
PRODUCT_ID="${PRODUCT_ID%%[[:cntrl:]]}"

CULTURE="en-us"
LANGIDS="1033"

SETUP_RELEASE_DIR=".\\releasedir"
BINARY_DIR="..\\..\\..\\VSCode-win32-${VSCODE_ARCH}"
LICENSE_DIR="..\\..\\..\\vscode"
PROGRAM_FILES_86=$( env | sed -n 's/^ProgramFiles(x86)=//p' )

if [[ -z "${1}" ]]; then
	OUTPUT_BASE_FILENAME="${APP_NAME}-${VSCODE_ARCH}-${RELEASE_VERSION}"
else
	OUTPUT_BASE_FILENAME="${APP_NAME}-${VSCODE_ARCH}-${1}-${RELEASE_VERSION}"
fi

if [[ "${VSCODE_ARCH}" == "ia32" ]]; then
   export PLATFORM="x86"
else
   export PLATFORM="${VSCODE_ARCH}"
fi

sed -i "s|@@PRODUCT_UPGRADE_CODE@@|${PRODUCT_UPGRADE_CODE}|g" .\\includes\\vscodium-variables.wxi
# The XSL uses @@PRODUCT_NAME@@ to match a <File Source="...\${NAME}.exe">. That
# must be the actual on-disk executable name (product.json nameShort), which may
# differ from PRODUCT_NAME (e.g. insider PRODUCT_NAME includes " - Insiders").
sed -i "s|@@PRODUCT_NAME@@|${WIN_EXE_NAME}|g" .\\vscodium.xsl

# The .wxl files hold user-visible strings, so they take the display name.
find i18n -name '*.wxl' -print0 | xargs -0 sed -i "s|@@PRODUCT_NAME@@|${PRODUCT_NAME}|g"

BuildSetupTranslationTransform() {
	local CULTURE=${1}
	local LANGID=${2}

	LANGIDS="${LANGIDS},${LANGID}"

	echo "Building setup translation for culture \"${CULTURE}\" with LangID \"${LANGID}\"..."

	"${WIX}bin\\light.exe" vscodium.wixobj "Files-${OUTPUT_BASE_FILENAME}.wixobj" -ext WixUIExtension -ext WixUtilExtension -ext WixNetFxExtension -spdb -cc "${TEMP}\\vscodium-cab-cache\\${PLATFORM}" -reusecab -out "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi" -loc "i18n\\vscodium.${CULTURE}.wxl" -cultures:"${CULTURE}" -sice:ICE60 -sice:ICE69

	cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\WiLangId.vbs" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi" Product "${LANGID}"

	"${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\x86\\msitran" -g "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.mst"

	cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\wisubstg.vbs" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.mst" "${LANGID}"

	cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\wisubstg.vbs" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi"

	rm -f "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.msi"
	rm -f "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.${CULTURE}.mst"
}

if [[ -z "${INSTALLER_VERSION}" ]]; then
  echo "Error: INSTALLER_VERSION is not set. Ensure get_repo.sh has run."
  exit 1
fi

"${WIX}bin\\heat.exe" dir "${BINARY_DIR}" -out "Files-${OUTPUT_BASE_FILENAME}.wxs" -t vscodium.xsl -gg -sfrag -scom -sreg -srd -ke -cg "AppFiles" -var var.ManufacturerName -var var.AppName -var var.AppCodeName -var var.ProductVersion -var var.IconDir -var var.LicenseDir -var var.BinaryDir -dr APPLICATIONFOLDER -platform "${PLATFORM}"
"${WIX}bin\\candle.exe" -arch "${PLATFORM}" vscodium.wxs "Files-${OUTPUT_BASE_FILENAME}.wxs" -ext WixUIExtension -ext WixUtilExtension -ext WixNetFxExtension -dManufacturerName="VSCodium" -dAppCodeName="${PRODUCT_CODE}" -dAppName="${PRODUCT_NAME}" -dProductVersion="${INSTALLER_VERSION}" -dProductId="${PRODUCT_ID}" -dBinaryDir="${BINARY_DIR}" -dIconDir="${ICON_DIR}" -dLicenseDir="${LICENSE_DIR}" -dSetupResourcesDir="${SETUP_RESOURCES_DIR}" -dCulture="${CULTURE}"
"${WIX}bin\\light.exe" vscodium.wixobj "Files-${OUTPUT_BASE_FILENAME}.wixobj" -ext WixUIExtension -ext WixUtilExtension -ext WixNetFxExtension -spdb -cc "${TEMP}\\vscodium-cab-cache\\${PLATFORM}" -out "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi" -loc "i18n\\vscodium.${CULTURE}.wxl" -cultures:"${CULTURE}" -sice:ICE60 -sice:ICE69

BuildSetupTranslationTransform de-de 1031
BuildSetupTranslationTransform es-es 3082
BuildSetupTranslationTransform fr-fr 1036
BuildSetupTranslationTransform it-it 1040
# WixUI_Advanced bug: https://github.com/wixtoolset/issues/issues/5909
# BuildSetupTranslationTransform ja-jp 1041
BuildSetupTranslationTransform ko-kr 1042
BuildSetupTranslationTransform ru-ru 1049
BuildSetupTranslationTransform zh-cn 2052
BuildSetupTranslationTransform zh-tw 1028

# Add all supported languages to MSI Package attribute
cscript "${PROGRAM_FILES_86}\\Windows Kits\\${WIN_SDK_MAJOR_VERSION}\\bin\\${WIN_SDK_FULL_VERSION}\\${PLATFORM}\\WiLangId.vbs" "${SETUP_RELEASE_DIR}\\${OUTPUT_BASE_FILENAME}.msi" Package "${LANGIDS}"

# Remove files we do not need any longer.
rm -rf "${TEMP}\\vscodium-cab-cache"
rm -f "Files-${OUTPUT_BASE_FILENAME}.wxs"
rm -f "Files-${OUTPUT_BASE_FILENAME}.wixobj"
rm -f "vscodium.wixobj"

cd "${CALLER_DIR}"
