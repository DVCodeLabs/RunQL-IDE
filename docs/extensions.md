<!-- order: 15 -->

# Extensions and Marketplace

## Table of Contents

- [Marketplace](#marketplace)
- [Open VSX in RunQL](#openvsx)
- [Use a different extension gallery](#switch-marketplace)
- [Self-host an extension gallery](#selfhost-marketplace)
- [Visual Studio Marketplace](#visual-studio-marketplace)
- [Proprietary debugging tools](#proprietary-debugging-tools)
- [Proprietary extensions](#proprietary-extensions)
- [VSIX workflow](#vsix-workflow)
- [Extensions compatibility](./extensions-compatibility.md)

## <a id="marketplace"></a>Marketplace

RunQL is a Code OSS based editor, so most functionality beyond the core app comes from extensions.

By default, RunQL is configured to use [Open VSX](https://open-vsx.org/) rather than the Microsoft Visual Studio Marketplace. That keeps the distributed product aligned with open source distribution constraints and avoids depending on Microsoft-only marketplace terms.

If an extension you need is missing from Open VSX, your options are:

- Ask the extension maintainer to publish to [Open VSX](https://open-vsx.org/).
- Submit a pull request to [open-vsx/publish-extensions](https://github.com/open-vsx/publish-extensions).
- Download a released `.vsix` from the extension’s source repository and install it manually.

## <a id="openvsx"></a>Open VSX in RunQL

Open VSX is the default extension gallery in RunQL. The Extensions view uses it automatically unless you override the gallery configuration.

## <a id="switch-marketplace"></a>Use a different extension gallery

You can point RunQL at a different gallery with environment variables:

- `VSCODE_GALLERY_SERVICE_URL`
- `VSCODE_GALLERY_ITEM_URL`
- `VSCODE_GALLERY_CACHE_URL`
- `VSCODE_GALLERY_CONTROL_URL`
- `VSCODE_GALLERY_EXTENSION_URL_TEMPLATE`
- `VSCODE_GALLERY_RESOURCE_URL_TEMPLATE`

You can also override the gallery in a user-level `product.json` under the RunQL config directory:

- Windows: `%APPDATA%\\RunQL`
- macOS: `~/Library/Application Support/RunQL`
- Linux: `$XDG_CONFIG_HOME/RunQL` or `~/.config/RunQL`

Example:

```jsonc
{
  "extensionsGallery": {
    "serviceUrl": "",
    "itemUrl": "",
    "cacheUrl": "",
    "controlUrl": "",
    "extensionUrlTemplate": "",
    "resourceUrlTemplate": ""
  }
}
```

## <a id="selfhost-marketplace"></a>Self-host an extension gallery

Self-hosting can make sense for regulated environments, air-gapped deployments, or teams that want a curated internal extension catalog.

Common options:

- [Open VSX](https://github.com/eclipse/openvsx)
- [code-marketplace](https://coder.com/blog/running-a-private-vs-code-extension-marketplace)

## <a id="visual-studio-marketplace"></a>Visual Studio Marketplace

The Microsoft marketplace terms are specific about use with Microsoft products and services. Because of that, this project does not rely on that marketplace as its default gallery.

If you choose to use it separately, review the applicable license and terms yourself:

- [Visual Studio Marketplace Terms of Use](https://aka.ms/vsmarketplace-ToU)

## <a id="proprietary-debugging-tools"></a>Proprietary debugging tools

Some Microsoft-published debugging components are licensed to work only with the official Microsoft build of VS Code. That affects certain workflows in Code OSS based editors such as RunQL.

One example is C# debugging, where community alternatives such as [netcoredbg](https://github.com/Samsung/netcoredbg) may be required depending on the extension.

## <a id="proprietary-extensions"></a>Proprietary extensions

Some marketplace extensions hard-code product checks or require Microsoft-only services. In a few cases, proposed API allow-listing can help, but many extensions still will not function correctly outside the official Microsoft distribution.

If you are evaluating an extension for RunQL, assume compatibility must be verified rather than assumed.

## <a id="vsix-workflow"></a>VSIX workflow

For RunQL itself, the built-in RunQL extension is sourced from released `.vsix` assets rather than copying source code directly into the IDE repository. That keeps IDE builds reproducible and aligned with released extension versions.

See:

- [docs/runql-release-automation-checklist.md](/Users/rob/Code/new-api/RunQL-IDE/docs/runql-release-automation-checklist.md)

## Extensions compatibility

See:

- [docs/extensions-compatibility.md](/Users/rob/Code/new-api/RunQL-IDE/docs/extensions-compatibility.md)
