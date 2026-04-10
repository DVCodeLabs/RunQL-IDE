<!-- order: 20 -->

# Migration

## Table of Contents

- [Manual migration from VS Code](#manual-migration)
- [Semi-automatic migration with Sync Settings](#semi-automatic-migration)

## <a id="manual-migration"></a>Manual migration from VS Code

If you are moving from Visual Studio Code to RunQL, the main things to migrate are:

- user settings
- keybindings
- snippets
- extensions

Visual Studio Code stores user settings in:

- Windows: `%APPDATA%\\Code\\User`
- macOS: `$HOME/Library/Application Support/Code/User`
- Linux: `$HOME/.config/Code/User`

RunQL stores user settings in:

- Windows: `%APPDATA%\\RunQL\\User`
- macOS: `$HOME/Library/Application Support/RunQL/User`
- Linux: `$HOME/.config/RunQL/User`

To migrate manually:

1. Open VS Code settings JSON.
2. Copy the contents into the matching RunQL `settings.json`.
3. Repeat for `keybindings.json` and any snippets you want to carry over.
4. Reinstall extensions from Open VSX or install compatible `.vsix` files manually.

Extension compatibility is not one-to-one. Some Microsoft marketplace extensions only work with the official Microsoft build.

See:

- [docs/extensions-compatibility.md](/Users/rob/Code/new-api/RunQL-IDE/docs/extensions-compatibility.md)

## <a id="semi-automatic-migration"></a>Semi-automatic migration with Sync Settings

The [Sync Settings](https://github.com/zokugun/vscode-sync-settings) extension can help move settings and extension lists between editors.

Typical flow:

1. Install the extension in both VS Code and RunQL.
2. Configure the backing repository in both editors.
3. Upload from VS Code.
4. Download into RunQL.
5. Wait until extension installation is complete before restarting RunQL.

This approach is convenient, but you should still review the final extension set for compatibility with RunQL.
