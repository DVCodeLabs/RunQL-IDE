# Contributing

Thanks for taking the time to contribute to RunQL.

#### Table Of Contents

- [Code of Conduct](#code-of-conduct)
- [Reporting Bugs](#reporting-bugs)
- [Making Changes](#making-changes)

## Code of Conduct

This project and everyone participating in it is governed by the [RunQL Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold it.

## Reporting Bugs

### Before Submitting an Issue

Before creating a bug report, please check existing issues and the local documentation in [`docs/`](./docs) first.
When you open an issue, include enough detail to reproduce the problem:

- operating system and architecture
- RunQL version
- whether the issue is in the IDE, the bundled RunQL extension, or the build pipeline
- clear reproduction steps

## Making Changes

If you want to make changes, start with:

- [docs/howto-build.md](./docs/howto-build.md)
- [docs/co-op-runql-ide-setup.md](./docs/co-op-runql-ide-setup.md)

### Building RunQL

To build RunQL locally, follow the build scripts documented in [docs/howto-build.md](./docs/howto-build.md).

### Updating patches

If you want to update the existing patches, please follow the section [`Patch Update Process - Semi-Automated`](./docs/howto-build.md#patch-update-process-semiauto).

### Add a new patch

- first, you need to build VSCodium
- first, build RunQL locally
- then use the command `./dev/patch.sh <your patch name>`, to initiate a new patch
- when the script pauses at `Press any key when the conflict have been resolved...`, open the `vscode` directory in the local app build
- run `npm run watch`
- run `./script/code.sh`
- make your changes
- press any key to continue the script `patch.sh`
