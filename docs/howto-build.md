<!-- order: 35 -->

# How to Build RunQL

## Table of Contents

- [Dependencies](#dependencies)
  - [Linux](#dependencies-linux)
  - [macOS](#dependencies-macos)
  - [Windows](#dependencies-windows)
- [Build for development](#build-dev)
- [Build for CI](#build-ci)
- [Build Snap](#build-snap)
- [Patch update process](#patch-update-process)

## <a id="dependencies"></a>Dependencies

- Node.js version from [/.nvmrc](/Users/rob/Code/new-api/RunQL-IDE/.nvmrc)
- `jq`
- `git`
- Python 3.11
- `rustup`

### <a id="dependencies-linux"></a>Linux

- `gcc`
- `g++`
- `make`
- `pkg-config`
- `libx11-dev`
- `libxkbfile-dev`
- `libsecret-1-dev`
- `libkrb5-dev`
- `fakeroot`
- `rpm`
- `rpmbuild`
- `dpkg`
- `imagemagick`
- `snapcraft`

### <a id="dependencies-macos"></a>macOS

Install the common dependencies, plus Xcode Command Line Tools.

For the project-specific local workflow, see:

- [docs/runql-release-automation-checklist.md](/Users/rob/Code/new-api/RunQL-IDE/docs/runql-release-automation-checklist.md)

### <a id="dependencies-windows"></a>Windows

Run the build scripts from Git Bash or WSL2.

Required tools:

- Git for Windows
- Node.js matching [/.nvmrc](/Users/rob/Code/new-api/RunQL-IDE/.nvmrc)
- `jq`
- 7-Zip
- Python 3.11
- Rustup

Optional:

- WiX Toolset v3 for MSI packaging

Verify the toolchain from Git Bash:

```bash
node --version
npm --version
jq --version
python3 --version
cargo --version
7z i 2>&1 | head -1
git --version
```

## <a id="build-dev"></a>Build for development

Use the local helper:

```bash
./dev/build.sh
```

Platform notes:

- Linux: `./dev/build.sh`
- macOS: `./dev/build.sh`
- Windows Git Bash: `"C:\\Program Files\\Git\\bin\\bash.exe" ./dev/build.sh`

Useful flags:

- `-i` build the insiders variant
- `-l` build against the latest upstream source
- `-o` skip the build step
- `-p` generate installers and packages
- `-s` reuse the existing `vscode/` checkout

## <a id="build-ci"></a>Build for CI

The stable automation lives in the repository workflow files:

- [stable-linux.yml](/Users/rob/Code/new-api/RunQL-IDE/.github/workflows/stable-linux.yml)
- [stable-macos.yml](/Users/rob/Code/new-api/RunQL-IDE/.github/workflows/stable-macos.yml)
- [stable-windows.yml](/Users/rob/Code/new-api/RunQL-IDE/.github/workflows/stable-windows.yml)

Those workflows are the source of truth for packaging and release automation. Use `./dev/build.sh` for local development, not as the canonical CI definition.

## <a id="build-snap"></a>Build Snap

```bash
cd ./stores/snapcraft/stable
snapcraft --use-lxd
review-tools.snap-review --allow-classic runql*.snap
```

## <a id="patch-update-process"></a>Patch update process

If an upstream update breaks a patch:

1. Run `./dev/build.sh`.
2. Identify the failing patch.
3. Rebase or rebuild the patch against the refreshed `vscode/` checkout.
4. Move the durable change back into `src/stable`, `src/insider`, or `patches/user` as appropriate.
5. Rebuild and verify.

The main project rule is unchanged: do not keep long-term customizations directly inside `vscode/`.
