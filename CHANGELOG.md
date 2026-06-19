# Changelog

## 1.0.0 — 2026-06-19
- Initial public release.
- Root-cause teardown of the Neewer X11 driver (rebranded MacroSilicon UsbDisplay).
- Identified the failure on macOS Tahoe (26): stale 2023 build `V3.0.6.29`
  (dev-signed, deprecated capture API, bare `/usr/local/bin` binary).
- Fix path: install current official **`V3.3.2.59`** (Developer-ID signed +
  notarized, `MSDisplayManager.app`, ScreenCaptureKit) — verified by teardown.
- Toolkit: `diagnose.sh`, `install-latest.sh`, `uninstall.sh`, `fix-permissions.sh`.
- Double-click `.command` installers + native dialogs; `pkgbuild`/`hdiutil` builders.
- Optional driver embedding via `fetch-driver.command` (vendor binary never committed).
- **Confirmed working:** macOS Tahoe 26 + MacBook M1 Pro (3rd display).
