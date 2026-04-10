# Patches

This page documents patches that RunQL carries on top of the upstream Code OSS and VSCodium base.

---

## fix-policies

**Replace `@vscode/policy-watcher` with `@vscodium/policy-watcher`**

The upstream policy watcher package used by VS Code reads Windows Group Policy values from Microsoft-specific registry paths.

The VSCodium patch replaces that watcher with `@vscodium/policy-watcher`, which uses a separate vendor name and therefore a different registry root.

That means Code OSS based products built through the VSCodium pipeline do not read policy settings from the same path as Microsoft VS Code.

If you are debugging enterprise policy behavior, inspect the current product branding and the VSCodium policy watcher implementation to confirm the exact registry path used by the build you shipped.

References:

- [VSCodium issue #2714](https://github.com/VSCodium/vscodium/issues/2714)
- [VSCodium policy-watcher](https://github.com/VSCodium/policy-watcher)
