#!/usr/bin/env bash
# build-dmg.command — double-click on a Mac to wrap the installer .pkg into a
# clean, branded .dmg (the familiar "drag/double-click" experience).
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"

NAME="Neewer-X11-macOS-Tahoe-Unofficial-Driver"
PKG="$ROOT/${NAME}-Installer.pkg"
DMG="$ROOT/$NAME.dmg"

# Build the pkg first if it isn't there yet.
[ -f "$PKG" ] || bash "$ROOT/installer/build-pkg.command"

STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"' EXIT
cp "$PKG" "$STAGE/"
cp "$ROOT/INSTALL.md"  "$STAGE/INSTALL.txt"  2>/dev/null || true
cp "$ROOT/README.md"   "$STAGE/README.txt"   2>/dev/null || true
cp "$ROOT/SOURCES.md"  "$STAGE/SOURCES.txt"  2>/dev/null || true

echo "==> Building $DMG"
hdiutil create -volname "$NAME" -srcfolder "$STAGE" -ov -format UDZO "$DMG"
echo "Done: $DMG"
echo "(Optional) sign the dmg:  codesign --sign \"Developer ID Application: ...\" \"$DMG\""
