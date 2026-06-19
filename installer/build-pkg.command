#!/usr/bin/env bash
# build-pkg.command — double-click on a Mac to build the installer .pkg with
# Apple's own pkgbuild. Produces an installable package from this repo.
#
# Optional signing (recommended, removes the "unidentified developer" warning):
#   SIGN_ID="Developer ID Installer: Your Name (TEAMID)" ./build-pkg.command
set -euo pipefail
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"

ID="de.tillheidrich.neewerx11fix"
VER="1.0.0"
NAME="Neewer-X11-macOS-Tahoe-Unofficial-Driver-Installer"
OUT="$ROOT/$NAME.pkg"

command -v pkgbuild >/dev/null || { echo "pkgbuild not found — run: xcode-select --install"; exit 1; }

BUILD="$(mktemp -d)"; trap 'rm -rf "$BUILD"' EXIT
PAY="$BUILD/payload/usr/local/share/neewer-x11-fix"
mkdir -p "$PAY"
cp "$ROOT"/scripts/*.sh "$PAY"/
cp "$ROOT"/README.md "$ROOT"/INSTALL.md "$ROOT"/SOURCES.md "$PAY"/ 2>/dev/null || true
chmod +x "$PAY"/*.sh
chmod +x "$ROOT/installer/scripts/postinstall"

# Embed the official driver if you fetched it (installer/fetch-driver.command).
DRV="$(ls "$ROOT"/installer/driver/*.pkg 2>/dev/null | head -1 || true)"
if [ -n "$DRV" ]; then
  mkdir -p "$PAY/driver"; cp "$DRV" "$PAY/driver/"
  echo "==> Embedding driver: $(basename "$DRV")  (installer will work offline)"
else
  echo "==> No driver in installer/driver/ — the installer will download it at install time."
  echo "    To embed it instead, run installer/fetch-driver.command first."
fi

echo "==> Building $OUT"
if [ -n "${SIGN_ID:-}" ]; then
  pkgbuild --root "$BUILD/payload" --scripts "$ROOT/installer/scripts" \
    --identifier "$ID" --version "$VER" --install-location / \
    --sign "$SIGN_ID" "$OUT"
  echo "Signed with: $SIGN_ID"
  echo "To notarize:  xcrun notarytool submit \"$OUT\" --keychain-profile <profile> --wait && xcrun stapler staple \"$OUT\""
else
  pkgbuild --root "$BUILD/payload" --scripts "$ROOT/installer/scripts" \
    --identifier "$ID" --version "$VER" --install-location / "$OUT"
  echo "Built UNSIGNED. For a trusted, double-click-clean installer, re-run with SIGN_ID set (see header)."
fi
echo "Done: $OUT"
