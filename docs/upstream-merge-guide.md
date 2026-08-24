# Upstream Merge Guide

How to pull VSCodium upstream changes into RunQL-IDE without breaking patches or branding.

## Architecture: Know What Lives Where

Before touching anything, understand the three zones:

| Zone | How it works | How we customize |
|------|-------------|-----------------|
| `vscode/` | Gitignored. Cloned fresh from Microsoft each build via `get_repo.sh` | Patch files in `patches/`. Never edit `vscode/` directly. |
| `patches/` | Git-tracked. Applied to `vscode/` by `prepare_vscode.sh` at build time. | This IS our customization layer. Safe to edit. |
| `build/`, `*.sh` | Git-tracked. Inherited from upstream VSCodium. Receives changes on merge. | Edit directly. Use variables (`${APP_NAME}`) not hardcoded strings. Resolve merge conflicts manually. |
| `product.json` | Git-tracked. Our overrides. Merged on top of upstream via `jq` in `prepare_vscode.sh`. | Edit directly. This is our file. |

> **Golden rule:** Never commit changes directly into `vscode/`. It is wiped and rebuilt every build. Your changes will vanish. All customizations to VS Code source go through `patches/`.

## Before You Start

- [ ] Make sure `main` is clean — no uncommitted work
- [ ] Create a branch: `upstream-merge/vscodium-X.YYY`
- [ ] Read the VSCodium release notes for the version you're pulling
- [ ] Note any files in `build/` or root scripts that changed upstream

## The Merge — Step by Step

### 1. Fetch and merge upstream

```bash
git remote add vscodium https://github.com/VSCodium/vscodium.git  # if not already added
git fetch vscodium
git merge vscodium/master --no-commit
```

The `--no-commit` lets you inspect everything before committing.

### 2. Resolve merge conflicts in root files

Expect conflicts in `prepare_vscode.sh`, `build/` scripts, and `get_repo.sh`. For each conflict:

- Accept upstream's structural changes
- Keep our RunQL-specific values where they use `${APP_NAME}` or other variables
- If upstream hardcoded "VSCodium" in a new spot, use the appropriate variable instead

> **Watch for:** Our branding patch (`00-installer-runql-branding`) targets the original Microsoft values in `code.iss` directly. It applies *before* the VSCodium sed commands run, making those seds harmless no-ops. If upstream changes the publisher or URL lines in `code.iss`, verify our patch context still matches.

### 3. Test that patches still apply

Run the build locally to check every patch applies cleanly:

```bash
./dev/build.sh -s
```

If a patch fails, you'll see which one. For each broken patch:

1. Look at what upstream changed in the file the patch targets
2. Rebuild the patch against the new `vscode/` checkout
3. Test the rebuilt patch applies

Refer to the patch reference below for what each patch does.

### 4. Full build and smoke test

```bash
./dev/build.sh -p
```

Verify:

- App launches and shows "RunQL" in the title bar, not VSCodium or VS Code
- About dialog shows correct version and branding
- The bundled RunQL extension loads
- On Windows: installer shows "RunQL" as publisher, not VSCodium
- Update check doesn't crash (it can fail to find an update — that's fine)

### 5. Commit and PR

```bash
git add -A
git commit -m "build(stable): update base to VSCodium X.YYY.ZZZZZ"
```

Open a PR against `main`. In the PR description, note:

- Which VSCodium version you merged
- Which patches needed rebuilding and why
- Any new upstream changes that affect RunQL customizations

## Patch Reference

### Global patches (`patches/*.patch`)

Applied on all platforms.

| Patch | What it does |
|-------|-------------|
| `00-update-rename-cache-path` | Renames the update cache directory from `vscode-*` to use `applicationName` from product.json, so RunQL doesn't collide with VS Code or VSCodium cache. |
| `11-update-use-github-release` | Replaces the update check to use GitHub Releases API instead of Microsoft's update server. Adds MSI installer support and the `Target`/`WindowsInstaller` types. |

### Windows patches (`patches/windows/*.patch`)

| Patch | What it does |
|-------|-------------|
| `00-installer-runql-branding` | Replaces "Microsoft Corporation" publisher and `code.visualstudio.com` URLs with "RunQL" / `runql.com` in `code.iss`. Targets the pre-sed state (the original Microsoft values). The sed commands in `prepare_vscode.sh` that later replace Microsoft → VSCodium become no-ops since the patch already changed those lines. |
| `00-installer-reset-uninstall-log` | Mitigates Inno Setup `unins000.dat` overflow. Backs up and resets the uninstall log when it exceeds 500 MB to prevent "EndOffset range exceeded" errors during silent background updates. |
| `00-update-prevent-duplicate-installer` | Prevents a race condition where a second Inno Setup installer spawns while one is already running. Checks the `runqlidesetup` mutex before launching. |

## Common Pitfalls

**Don't rename VSCodium infrastructure.** Files named `vscodium.wxs`, `vscodium.wixobj`, container images like `vscodium/vscodium-linux-build-agent` — these are build plumbing. Renaming them to "runql" breaks upstream merges for zero user-facing benefit.

**Branding patch targets the original Microsoft values.** The `00-installer-runql-branding.patch` replaces "Microsoft Corporation" and `code.visualstudio.com` directly (the pre-sed state), making the later VSCodium sed commands in `prepare_vscode.sh` harmless no-ops. If upstream changes the original publisher or URL lines in `code.iss`, the patch context may need updating.

**Patches apply in alphabetical order.** The `00-` prefix runs before `11-`, etc. If you add a new patch, name it so it applies after any patches it depends on.

**`product.json` wins last.** Our root `product.json` is merged on top of upstream's via `jq -s '.[0] * .[1]'` in `prepare_vscode.sh`. If upstream adds a new field we need to override, add it to our `product.json` — don't patch theirs.

## If a Patch Breaks

The build will tell you which patch failed. Here's how to fix it:

1. Run `./dev/build.sh -o` to get a fresh `vscode/` checkout without building
2. Manually apply all patches up to (but not including) the broken one
3. Open the broken patch and the target file side by side
4. Find what upstream changed — usually the context lines around the patch site shifted
5. Make the fix manually in `vscode/`, then generate a new patch:
   ```bash
   cd vscode
   git diff src/path/to/file.ts > ../patches/windows/00-my-patch.patch
   ```
6. Test the full build with the new patch

## Quick Reference

| I need to… | Do this |
|-----------|---------|
| Change RunQL app name, icons, identifiers | Edit `product.json` |
| Modify VS Code source (editor, update service, etc.) | Create a patch in `patches/` |
| Fix Windows installer branding | Update `patches/windows/00-installer-runql-branding.patch` |
| Change build/packaging scripts | Edit `build/` directly, use variables for RunQL-specific values |
| Override a product.json field upstream added | Add the field to our root `product.json` |
| Add a new VS Code source modification | Edit in `vscode/`, generate patch with `git diff`, save to `patches/` |
