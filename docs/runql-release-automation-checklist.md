# RunQL Release Automation Checklist

This checklist tracks the work required so a `RunQL` extension release automatically builds and publishes fresh `RunQL` IDE artifacts.

## Scope

- Supported IDE targets:
  - macOS `arm64`
  - Linux `x64`
  - Linux `arm64`
  - Windows `x64`
- Trigger source:
  - `RunQL` (extension) GitHub release
- Built-in extension source of truth:
  - released `.vsix` assets
- IDE release version format:
  - `<base_vscodium_release><extension_major_2digits><extension_minor_2digits><extension_patch_2digits>`
  - example: `1.112.02387010402`

## RunQL-IDE Repo Work

- Update the stable workflow triggers to accept `repository_dispatch` event type `runql-client-release`.
- Reduce stable platform matrices to the four supported extension targets.
- Add workflow env for:
  - `RUNQL_CLIENT_REPO`
  - `RUNQL_CLIENT_TAG`
  - `RUNQL_CLIENT_VERSION`
- Add a reusable helper to download and install a released `RunQL` VSIX.
- On macOS:
  - install the extension into `src/stable/extensions/runql-client` before the full build.
- On Linux and Windows:
  - inject the platform-specific extension into the unpacked `vscode/extensions/runql-client` directory during the packaging phase.
- Update dispatch handling so `repository_dispatch` means:
  - deploy build
  - new release
- Derive `BASE_RELEASE_VERSION` and final `RELEASE_VERSION` from:
  - upstream VSCodium base
  - dispatched `RunQL` extension version
- Update release notes so each release states:
  - VS Code base version
  - base VSCodium release version
  - bundled `RunQL` extension version
- Rename workflow env defaults from VSCodium branding to RunQL branding.
- Disable VSCodium-specific post-release jobs for non-VSCodium repos:
  - versions repo update
  - AUR
  - Snap
  - external repository dispatches
  - WinGet

## RunQL (extension) Repo Work

- Keep the existing release package matrix:
  - `linux-x64`
  - `linux-arm64`
  - `darwin-arm64`
  - `win32-x64`
- Add a final workflow job after release asset upload.
- Dispatch `RunQL-IDE` with payload:
  - `extension_tag`
  - `extension_version`
  - `source_repo`

## Required Secrets / Setup

- In the `RunQL` (extension) repo:
  - token that can send `repository_dispatch` to the `RunQL-IDE` repo
- In `RunQL-IDE`:
  - existing release token for GitHub releases
  - optional signing/notarization secrets if signed installers are required

## Validation

- Trigger a test release from the `RunQL` (extension) repo.
- Confirm `RunQL-IDE` starts automatically.
- Confirm IDE artifacts are built only for the four supported targets.
- Confirm the release tag matches the encoded version scheme.
- Confirm the built app contains the matching bundled `RunQL` extension version.
