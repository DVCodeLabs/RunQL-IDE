<!-- order: 16 -->

# AI Chat and GitHub Copilot

RunQL ships with telemetry disabled. AI chat features are available only if they are explicitly enabled in the build and in user settings.

## Install GitHub Copilot

GitHub Copilot is distributed through the Microsoft Visual Studio Marketplace, not Open VSX. RunQL uses Open VSX by default, so Copilot will not appear in extension search unless you configure a different gallery or install a compatible `.vsix` manually.

Create or update this file:

- Windows: `%APPDATA%\RunQL\product.json`
- macOS: `~/Library/Application Support/RunQL/product.json`
- Linux: `$XDG_CONFIG_HOME/RunQL/product.json` or `~/.config/RunQL/product.json`

Use this content:

```json
{
  "extensionsGallery": {
    "serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery",
    "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index",
    "itemUrl": "https://marketplace.visualstudio.com/items"
  }
}
```

Restart RunQL, then search for `GitHub Copilot` in Extensions.

## Enable AI chat features

In Settings, make sure:

```json
{
  "chat.disableAIFeatures": false
}
```

If your local build still hides chat features, check the repository patch that disables Copilot defaults:

- [patches/disable-copilot.patch](/Users/rob/Code/new-api/RunQL-IDE/patches/disable-copilot.patch)

For the RunQL build, this patch should leave AI chat enabled when that is the intended product behavior.

## Product configuration

Advanced chat integrations may also require product-level configuration in the generated `product.json`.

For local reference, RunQL user data is stored under the product-specific application support folder:

- Windows: `%APPDATA%\RunQL`
- macOS: `~/Library/Application Support/RunQL`
- Linux: `$XDG_CONFIG_HOME/RunQL` or `~/.config/RunQL`

If you are wiring a custom chat integration into a Code OSS based build, the upstream guidance from the Copilot Chat repository is still the best reference:

- [Running with Code OSS](https://github.com/microsoft/vscode-copilot-chat/blob/main/CONTRIBUTING.md#running-with-code-oss)

Typical product fields involved are:

- `trustedExtensionAuthAccess`
- `defaultChatAgent`
