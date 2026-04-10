<!-- order: 10 -->

# Telemetry

This page explains how RunQL handles telemetry, online services, and related privacy defaults.

## Table of contents

- [Telemetry in RunQL](#telemetry)
- [Replacements to Microsoft online services](#replacements)
- [Checking for telemetry](#checking)
- [Announcements](#announcements)
- [Malicious and deprecated extensions](#malicious-extensions)

## <a id="telemetry"></a>Telemetry in RunQL

RunQL is built on an open source Code OSS and VSCodium pipeline, and the distributed product is configured with telemetry disabled by default.

Important defaults include:

```text
telemetry.telemetryLevel
telemetry.enableCrashReporter
telemetry.enableTelemetry
telemetry.editStats.enabled
workbench.enableExperiments
workbench.settings.enableNaturalLanguageSearch
workbench.commandPalette.experimental.enableNaturalLanguageSearch
```

You should still review any setting tagged with `@tag:usesOnlineServices`, because extensions and optional services can introduce their own network behavior.

Some third-party extensions also send telemetry independently. That is outside the control of the core RunQL build.

### Update services

If you want to minimize background network activity further, review:

- `update.mode`
- `update.enableWindowsBackgroundUpdates`
- `extensions.autoUpdate`
- `extensions.autoCheckUpdates`

On Linux, application update behavior is often disabled or managed externally through the package manager.

### Feedback telemetry

The `Report Issue...` flow may still depend on feedback-related settings. Review those settings separately if you want the most restrictive configuration possible.

## <a id="replacements"></a>Replacements to Microsoft online services

RunQL does not use Microsoft telemetry endpoints as its default product configuration.

By default:

- extension discovery uses Open VSX
- product branding and update behavior come from the RunQL/VSCodium build pipeline

## <a id="checking"></a>Checking for telemetry

If you want to verify network behavior yourself, use tools such as:

- Wireshark
- Little Snitch on macOS
- GlassWire on Windows

## <a id="announcements"></a>Announcements

The welcome experience can display announcements from the project’s configured sources.

If you do not want that behavior, disable:

- `workbench.welcomePage.extraAnnouncements`

## <a id="malicious-extensions"></a>Malicious and deprecated extensions

The extension safety list is loaded from:

- [Eclipse Open VSX extension-control list](https://raw.githubusercontent.com/EclipseFdn/publish-extensions/refs/heads/master/extension-control/extensions.json)

If you disable:

- `extensions.excludeUnsafes`

you reduce external checks, but you also reduce protection against known unsafe extensions.
