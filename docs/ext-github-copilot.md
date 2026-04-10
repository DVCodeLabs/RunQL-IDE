<!-- order: 16 -->

# AI Chat and GitHub Copilot

RunQL ships with telemetry disabled. AI chat features are available only if they are explicitly enabled in the build and in user settings.

## Enable AI chat features

In Settings, make sure:

```json
"chat.disableAIFeatures": false
```

If your local build still hides chat features, check the repository patch that disables Copilot defaults:

- [patches/disable-copilot.patch](/Users/rob/Code/new-api/RunQL-IDE/patches/disable-copilot.patch)

For the RunQL build, this patch should leave AI chat enabled when that is the intended product behavior.

## Product configuration

Advanced chat integrations may also require product-level configuration in the generated `product.json`.

For local reference, RunQL user data is stored under the product-specific application support folder:

- Windows: `%APPDATA%\\RunQL`
- macOS: `~/Library/Application Support/RunQL`
- Linux: `$XDG_CONFIG_HOME/RunQL` or `~/.config/RunQL`

If you are wiring a custom chat integration into a Code OSS based build, the upstream guidance from the Copilot Chat repository is still the best reference:

- [Running with Code OSS](https://github.com/microsoft/vscode-copilot-chat/blob/main/CONTRIBUTING.md#running-with-code-oss)

Typical product fields involved are:

- `trustedExtensionAuthAccess`
- `defaultChatAgent`
