<!-- order: 25 -->

# Troubleshooting

## Table of Contents

- [Linux](#linux)
- [Windows](#windows)

## <a id="linux"></a>Linux

### Fonts showing up as rectangles

```bash
rm -rf ~/.cache/fontconfig
rm -rf ~/snap/codium/common/.cache
fc-cache -r
```

### Text or the full interface does not appear

This is usually a GPU cache or driver issue in the Electron stack.

Try:

```bash
rm -rf ~/.config/RunQL/GPUCache
```

### Flatpak issues

If you are packaging or testing a Flatpak variant, start with the common sandbox checks:

- verify host command access with `flatpak-spawn --host <COMMAND>`
- verify any required SDKs are installed
- review the package-specific FAQ for the Flatpak you are testing

### Remote SSH does not work

Use a compatible SSH extension such as [Open Remote - SSH](https://open-vsx.org/extension/jeanp413/open-remote-ssh).

On the server, make sure `AllowTcpForwarding yes` is enabled in `sshd_config`.

### The window does not show up

On Wayland, try:

```bash
runql-ide --verbose
runql-ide --ozone-platform=x11
```

## <a id="windows"></a>Windows

### Group Policy Objects are ignored

RunQL inherits the VSCodium policy watcher behavior rather than the Microsoft VS Code policy path.

If you are deploying Group Policy for RunQL, confirm the registry path that matches the current branded build instead of assuming the Microsoft VS Code path will work.

See:

- [docs/patches.md](/Users/rob/Code/new-api/RunQL-IDE/docs/patches.md)

### "Open with RunQL" missing from context menu

If the context menu entry does not appear after installation:

1. Re-run the installer and enable the Explorer context menu option.
2. On Windows 11, check the classic context menu with Shift + right-click.
3. If needed, verify the registry entries point at the actual installed `RunQL.exe` path.

### Windows Defender flags the installer

Unsigned or newly published binaries can trigger false positives.

Only download installers from the official RunQL releases page:

- [RunQL Releases](https://github.com/DVCodeLabs/RunQL-IDE/releases)

Then verify the published checksums before running the installer.
