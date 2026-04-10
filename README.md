<div align="center">
  <br />
  <img src="./icons/stable/runql-ide.svg" alt="RunQL Logo" width="200" />
  <h1>RunQL</h1>
  <h3>The open source SQL editor built for data work with AI</h3>
</div>

<div align="center">

[![License](https://img.shields.io/github/license/DVCodeLabs/RunQL-IDE.svg)](https://github.com/DVCodeLabs/RunQL-IDE/blob/master/LICENSE)
[![Release](https://img.shields.io/github/release/DVCodeLabs/RunQL-IDE.svg)](https://github.com/DVCodeLabs/RunQL-IDE/releases)
[![Build Linux](https://img.shields.io/github/actions/workflow/status/DVCodeLabs/RunQL-IDE/stable-linux.yml?branch=master&label=build%28linux%29)](https://github.com/DVCodeLabs/RunQL-IDE/actions/workflows/stable-linux.yml?query=branch%3Amaster)
[![Build macOS](https://img.shields.io/github/actions/workflow/status/DVCodeLabs/RunQL-IDE/stable-macos.yml?branch=master&label=build%28macOS%29)](https://github.com/DVCodeLabs/RunQL-IDE/actions/workflows/stable-macos.yml?query=branch%3Amaster)
[![Build Windows](https://img.shields.io/github/actions/workflow/status/DVCodeLabs/RunQL-IDE/stable-windows.yml?branch=master&label=build%28windows%29)](https://github.com/DVCodeLabs/RunQL-IDE/actions/workflows/stable-windows.yml?query=branch%3Amaster)

</div>

RunQL is the VS Code based SQL editor built for data work with AI. It keeps schemas, ERDs, query metadata, and documentation as files in your workspace so your team and your AI tools have real database context instead of guessing.

This repository contains the open source desktop app build for RunQL. It is built on top of [VSCodium](https://github.com/VSCodium/vscodium), which in turn builds from Microsoft’s open source [Code OSS / `vscode`](https://github.com/microsoft/vscode) source.

For the product overview and open source details, see:

- [RunQL Open Source](https://runql.com/opensource/)
- [RunQL Extension on GitHub](https://github.com/DVCodeLabs/RunQL)

## What RunQL Does

- Connect to PostgreSQL, MySQL, and DuckDB directly, with an extension API for more databases
- Generate schema documentation, ERDs, and structured artifacts as local files
- Index saved SQL so queries are searchable by title, tags, SQL, and metadata
- Keep charts, schema snapshots, and docs in version control alongside application code
- Support optional AI workflows with your provider of choice

## Repositories

- [RunQL-IDE](https://github.com/DVCodeLabs/RunQL-IDE)
  - this repository
  - builds and packages the desktop application
- [RunQL](https://github.com/DVCodeLabs/RunQL)
  - the main RunQL extension repository
  - ships the built-in extension bundled into the IDE releases

## Downloads

Download the latest desktop builds from:

- [RunQL Releases](https://github.com/DVCodeLabs/RunQL-IDE/releases)

Install the extension-only version from:

- [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=RunQL-VSCode-Extension.runql)

## Build

Build instructions live in:

- [docs/howto-build.md](./docs/howto-build.md)
- [docs/co-op-runql-ide-setup.md](./docs/co-op-runql-ide-setup.md)

## Supported Platforms

Current release targets:

- macOS arm64
- Linux x64
- Linux arm64
- Windows x64

## Open Source Notes

- RunQL is MIT licensed
- This app is built from open source Code OSS sources
- Telemetry is disabled in the distributed RunQL build
- The default extension registry is Open VSX

## Contributing

Please read:

- [CONTRIBUTING.md](./CONTRIBUTING.md)
- [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)

## Attribution

RunQL is built on top of:

- [VSCodium](https://github.com/VSCodium/vscodium)
- [Microsoft vscode / Code OSS](https://github.com/microsoft/vscode)

Those upstream projects made this work possible.
