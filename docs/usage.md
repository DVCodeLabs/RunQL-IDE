<!-- order: 25 -->

# Usage

## Table of Contents

- [Sign in with GitHub](#signin-github)
- [Accounts authentication](./accounts-authentication.md)
- [Portable mode](#portable)
- [Default file manager on Linux](#file-manager)
- [Press and hold on macOS](#press-and-hold)
- [Open RunQL from the terminal](#terminal-support)

## <a id="signin-github"></a>Sign in with GitHub

In RunQL, GitHub sign-in flows may rely on a Personal Access Token depending on the extension and authentication path being used.

See:

- [GitHub Personal Access Token documentation](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token)

If a Linux login flow fails with a keychain error, install `gnome-keyring`.

## <a id="portable"></a>Portable mode

Portable mode generally follows the same model as VS Code, but the actual data folder name depends on the current product branding and packaged output. Verify the final packaged app behavior before depending on portable mode in automation.

## <a id="file-manager"></a>Default file manager on Linux

If RunQL becomes the default application for opening directories, define the intended file manager explicitly in `~/.config/mimeapps.list`:

```ini
[Default Applications]
inode/directory=org.gnome.Nautilus.desktop;
```

To inspect what your system currently associates with directories:

```bash
grep directory /usr/share/applications/mimeinfo.cache
```

## <a id="press-and-hold"></a>Press and hold on macOS

If you want key repeat instead of accent selection:

```bash
defaults write com.dvcode.runqlide ApplePressAndHoldEnabled -bool false
```

## <a id="terminal-support"></a>Open RunQL from the terminal

On macOS and Windows, install the shell command from the Command Palette.

Then you can open files or folders directly:

```bash
runql-ide .
runql-ide file.txt
```

If you later rename the shipped CLI to `runql`, use that command instead. The exact executable name depends on the packaged product settings and installer behavior.

On Linux package installs, the launcher should be added to `PATH` automatically.
