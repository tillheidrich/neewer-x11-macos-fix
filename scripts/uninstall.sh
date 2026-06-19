#!/usr/bin/env bash
# uninstall.sh — completely remove the MacroSilicon UsbDisplay driver.
# The driver has NO self-update mechanism, so a clean removal before reinstalling
# is the reliable path. Requires admin (sudo).
set -uo pipefail

APP=/Applications/MSDisplayManager.app
BIN=/usr/local/bin/MacUsbDisplay
UNINST=/usr/local/bin/usbdisplay_uninstall
PLIST=/Library/LaunchAgents/com.macrosilicon.usbdisplay.plist
LABEL=com.macrosilicon.usbdisplay

echo "==> Unloading the LaunchAgent ..."
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null \
  || launchctl unload "$PLIST" 2>/dev/null || true

echo "==> Stopping running processes ..."
pkill -f MSDisplayManager 2>/dev/null || true
pkill -f MacUsbDisplay 2>/dev/null || true

echo "==> Running the vendor uninstaller if present ..."
if [ -x "$UNINST" ]; then
  sudo "$UNINST" || true
fi

echo "==> Removing files (new app layout + legacy paths) ..."
sudo rm -rf "$APP" /usr/local/bin/MSUsbDisplay.app /usr/local/bin/usbdisplay_uninstall.app
sudo rm -f "$BIN" "$UNINST" "$PLIST"

echo "==> Forgetting the package receipt ..."
sudo pkgutil --forget "$LABEL" 2>/dev/null || true

echo "==> Done. Old driver removed."
echo "    (A logout/restart is recommended before reinstalling.)"
