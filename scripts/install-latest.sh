#!/usr/bin/env bash
# install-latest.sh — install the current official MacroSilicon UsbDisplay driver
# that supports macOS up to 26.2 (Tahoe). Removes the old build first, because the
# driver does NOT self-update.
#
# Usage:
#   ./install-latest.sh                 # installs the pinned latest version below
#   ./install-latest.sh <url-to-pkg>    # installs a specific build you pass in
set -euo pipefail

# --- Pinned latest known-good build (per MacroSilicon's own readme: 3.3.x = macOS 12.3–26.2)
DEFAULT_URL="http://www.macrosilicon.com:9080/download/USBDisplay/macOS/Installer/MacroSilicon_UsbDisplay_V3.3.2.59_20260320_1655.pkg"
URL="${1:-$DEFAULT_URL}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
PKG="$TMP/MacroSilicon_UsbDisplay.pkg"
trap 'rm -rf "$TMP"' EXIT

echo "==> Downloading driver:"
echo "    $URL"
curl -fL --retry 3 --connect-timeout 20 -o "$PKG" "$URL"

echo "==> Sanity-checking the download ..."
file "$PKG" | grep -qiE "xar|installer|archive" || { echo "ERROR: not a valid .pkg"; exit 1; }
echo "    Signature / notarization status:"
pkgutil --check-signature "$PKG" 2>&1 | sed 's/^/      /' || true

echo "==> Removing any existing (old) driver first ..."
if [ -x "$SCRIPT_DIR/uninstall.sh" ]; then
  bash "$SCRIPT_DIR/uninstall.sh" || true
fi

echo "==> Installing (you'll be asked for your admin password) ..."
sudo installer -pkg "$PKG" -target /

cat <<'EOF'

==> Installed.

NEXT STEPS (required):
  1. RESTART your Mac (the installer requests this).
  2. Grant Screen Recording to the driver:
       System Settings > Privacy & Security > Screen & System Audio Recording
       -> enable "MacUsbDisplay"  (add /usr/local/bin/MacUsbDisplay if it's missing)
  3. Log out & back in (or restart again).
  4. Plug in / power the X11, then check System Settings > Displays.

Tip: run ./fix-permissions.sh after the reboot, and ./diagnose.sh if anything is off.
EOF
