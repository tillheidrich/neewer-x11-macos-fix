#!/usr/bin/env bash
# fetch-driver.command — double-click on your Mac to download the current OFFICIAL
# MacroSilicon driver into installer/driver/ so the builder can embed it.
# (Runs on YOUR machine, straight from the vendor — nothing is redistributed by us.)
set -euo pipefail
cd "$(dirname "$0")"

URL="http://www.macrosilicon.com:9080/download/USBDisplay/macOS/Installer/MacroSilicon_UsbDisplay_V3.3.2.59_20260320_1655.pkg"
DEST="driver"
mkdir -p "$DEST"
OUT="$DEST/$(basename "$URL")"

echo "==> Downloading the official MacroSilicon driver:"
echo "    $URL"
curl -fL --retry 3 --connect-timeout 20 -o "$OUT" "$URL"

echo "==> Verifying it's a real macOS package…"
file "$OUT" | grep -qiE "xar|archive" || { echo "ERROR: not a valid .pkg"; exit 1; }
pkgutil --check-signature "$OUT" 2>&1 | sed 's/^/    /' || true

echo "==> Saved: $OUT"
echo "Now double-click installer/build-pkg.command — it will embed this driver."
